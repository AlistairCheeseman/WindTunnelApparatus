using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Shapes;
using System.Collections.ObjectModel;
using System.Windows.Threading;
using System.IO.Ports;
namespace serialcharter
{
    /// <summary>
    /// Interaction logic for Window1.xaml
    /// </summary>
    public partial class Window1 : Window
    {
       static ObservableCollection<KeyValuePair<double, double>> Power = new ObservableCollection<KeyValuePair<double, double>>();
        SerialPort SP;
        public Window1()
        {
            InitializeComponent();
            showColumnChart();
            initialiseserial();
            DispatcherTimer timer = new DispatcherTimer();
            timer.Interval = new TimeSpan(0, 0, 0,0,500);  // per 500 milliseconds, could change it
            timer.Tick += new EventHandler(timer_Tick);
            timer.IsEnabled = false; //set this to true to spawn data
        }

      static  double i = 3;
        Random random = new Random(DateTime.Now.Millisecond);
        void timer_Tick(object sender, EventArgs e)
        {
            Power.Add(new KeyValuePair<double, double>(i, random.NextDouble()*100));
            i += 3;
        }

        private void showColumnChart()
        {
            lineChart.DataContext = Power;
        }
        private void initialiseserial()
        {
            SP = new SerialPort();
            SP.PortName = "COM10";
            Console.WriteLine("Com port: " + SP.PortName.ToString());
            SP.BaudRate = 2000000;
            Console.WriteLine("Baud rate: " + SP.BaudRate.ToString());

            Console.WriteLine("Stop bit: " + SP.StopBits.ToString());
            Console.WriteLine("Parity bit: " + SP.Parity.ToString());
            Console.WriteLine("Read Timeout: " + SP.ReadTimeout.ToString());
            SP.Handshake = Handshake.XOnXOff;
            SP.DataReceived += sp_DataReceived;
            SP.Open();

            int test = SP.BaseStream.ReadByte();
            Console.WriteLine(test.ToString());
        }
        static string assembling;
        private void sp_DataReceived(object sender, SerialDataReceivedEventArgs e)
        {
            SerialPort sep = (SerialPort)sender;
            string indata = sep.ReadExisting();
            Console.Write(indata);
            string[] data;

   data = indata.Split(Environment.NewLine.ToCharArray(),StringSplitOptions.RemoveEmptyEntries);
   foreach (string val in data)
   {
      Dispatcher.Invoke(DispatcherPriority.Normal, (Action)(() =>
       {
           double value;
           if (double.TryParse(val,out value))
           {   Power.Add(new KeyValuePair<double, double>(i,value));
               i += 3;}
            
             
          
       }));    
     
   }

        }
      
        private void Window_Closed(object sender, EventArgs e)
        {
            SP.Close();
        }

    }
}
