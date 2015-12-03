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
    //class to hold data
    public class data
    {
        public data(double X, decimal Y)
        {
            this.x = X;
            this.y = Y;
        }
        public double x { get; set; }
        public decimal y { get; set; }
    }
    /// <summary>
    /// Interaction logic for Window1.xaml
    /// </summary>
    public partial class Window1 : Window
    {
        //y = mx+c
        private const decimal c = -1225.775135M;
        private const decimal m = 0.1496398871M;

        static ObservableCollection<data> Data = new ObservableCollection<data>();
        SerialPort SP;
        DateTime Start;
        public Window1()
        {
            InitializeComponent();
            lineChart.DataContext = Data; // set the data context for the chart
            StartBtn.IsEnabled = true;
            StopBtn.IsEnabled = false;
            Comtxt.Text = "COM10";
            baudtxt.Text = 9600.ToString();
            DispatcherTimer timer = new DispatcherTimer();
            timer.Interval = new TimeSpan(0, 0, 0, 0, 500);  // per 500 milliseconds, could change it
            timer.Tick += new EventHandler(timer_Tick);
            timer.IsEnabled = false; //set this to true to spawn data
        }
        Random random = new Random(DateTime.Now.Millisecond);
        void timer_Tick(object sender, EventArgs e)
        {
            Data.Add(new data((DateTime.Now - Start).TotalMilliseconds, (decimal)random.NextDouble() * 100));
        }
        private void initialiseserial()
        {
            try
            {
                SP = new SerialPort();
                SP.PortName = Comtxt.Text;
                Console.WriteLine("Com port: " + SP.PortName.ToString());
                int baud = int.Parse(baudtxt.Text);
                SP.BaudRate = baud;
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
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message);
                StartBtn.IsEnabled = true;
                StopBtn.IsEnabled = false;
            }
        }
        string tail = String.Empty;
        public delegate void MyDelegate(string inData);
        private void sp_DataReceived(object sender, SerialDataReceivedEventArgs e)
        {
            SerialPort sep = (SerialPort)sender;
            string indata = sep.ReadExisting();

            this.Dispatcher.BeginInvoke(new MyDelegate(ProcessData), DispatcherPriority.Normal, indata);
        }

        public void ProcessData(string inData)
        {
            inData = inData.Replace("\r", String.Empty); // clear out the extra rubbish
            inData = tail + inData; // add the tail of the last packet to the beginning of this packet.
            if (!inData.EndsWith("\n"))
                if (inData.Contains('\n'))
                {
                    tail = inData.Substring(inData.LastIndexOf('\n')); // get the incomplete tail.
                    inData = inData.Substring(0, inData.LastIndexOf('\n')); // make sure to remove the incomplete tail.
                }
                else
                {
                    tail = inData;
                    inData = string.Empty;
                }
            else
                tail = string.Empty;
           

            string[] buffer;
            buffer = inData.Split("\n".ToCharArray(), StringSplitOptions.RemoveEmptyEntries);
            foreach (string val in buffer)
            {

                double value;
                if (double.TryParse(val, out value))
                {
                    if (value < 1000 | value > 16000)
                    {
                        //throw data out.
                    }
                    else
                    {
                        if (value != 8000)
                        {
                            Console.WriteLine(value.ToString());
                        }
                        //y=mx+c
                        decimal Pa = m * ((decimal)value) + c;
                        Data.Add(new data((DateTime.Now - Start).TotalMilliseconds, Pa));
                    }
                    
                }
            }
        }

        private void Window_Closed(object sender, EventArgs e)
        {
            if (SP.IsOpen == true)
                SP.Close();
        }

        private void StartBtn_Click(object sender, RoutedEventArgs e)
        {
            StopBtn.IsEnabled = true;
            StartBtn.IsEnabled = false;
            Data = new ObservableCollection<data>();
            Start = DateTime.Now;
            initialiseserial();
            lineChart.DataContext = Data; // set the data context for the chart

        }

        private void StopBtn_Click(object sender, RoutedEventArgs e)
        {
            if (SP.IsOpen == true)
            {
                SP.DataReceived -= sp_DataReceived;
                SP.Close();
            }
            StartBtn.IsEnabled = true;
            StopBtn.IsEnabled = false;
        }

        private void ExportBtn_Click(object sender, RoutedEventArgs e)
        {

            if (System.IO.File.Exists("data.csv"))
            {
                System.IO.File.Delete("data.csv");
            }
            string writebuffer = string.Empty;
            writebuffer += "Milliseconds, Value\n";
            foreach (data d in Data)
            {

                writebuffer += d.x.ToString() + ", " + d.y.ToString() + "\n";
            }
            System.IO.File.WriteAllText("data.csv", writebuffer);
            MessageBox.Show(String.Format("Export Complete, {0} entries saved", Data.Count()));
        }
    }
}
