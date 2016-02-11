using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.IO.Ports;
using System.Windows.Threading;
using Model;

namespace ViewModel.SensorControllers
{
    public class PressureController
    {
        //y = mx+c
        private const decimal c = -1225.775135M;
        private const decimal m = 0.1496398871M;
        SerialPort SP;
        Dispatcher dispatcher;
        System.IO.FileStream FS;
        bool isConnected
        {
            get; set;
        } = false;
        public PressureController(Dispatcher dis)
        {
            SP = new SerialPort();
            SP.BaudRate = 2000000;

            isConnected = false;
            dispatcher = dis;
        }
        public void Connect(string ComPort)
        {
            try
            {
                SP.PortName = ComPort;
                SP.Open();
                FS = System.IO.File.OpenWrite("PressureLog");
                // let some data gather before we add the event handler
                System.Threading.Tasks.Task.Delay(5000);
                SP.DataReceived += SP_DataReceived; // create the data receive trigger
                if (SP.IsOpen == true)
                    isConnected = true;
            }
            catch (Exception)
            {
                isConnected = false;
                Console.ForegroundColor = ConsoleColor.Red;
                Console.WriteLine("COULD NOT OPEN SERIAL PORT");
                Console.ForegroundColor = ConsoleColor.White;
            }
        }
        public void Disconnect()
        {
            FS.Close();
            SP.DataReceived -= SP_DataReceived;
            SP.Close();
            SP = null;
            isConnected = false;
           
        }

        private void SP_DataReceived(object sender, SerialDataReceivedEventArgs e)
        {
            byte[] buffer = new byte[999]; // a big buffer as we can receive a lot of data.
            ((SerialPort)sender).Read(buffer, 0, ((SerialPort)sender).BytesToRead);

            this.dispatcher.BeginInvoke(new MyDelegate(ProcessData), DispatcherPriority.Normal, buffer);
        }
        public delegate void MyDelegate(byte[] inData);

        /// <summary>
        ///  receive data burst.
        /// </summary>
        /// <param name="inData"></param>
        public void ProcessData(byte[] inData)
        {
            string newData = String.Empty;
            // this routine has to sort the data into new lines.
            foreach (byte t in inData)
            {
                int val = t;
                newData += val.ToString();
                FS.WriteByte(t);
            }
            Console.Write(newData);
        }
   
    }
}
