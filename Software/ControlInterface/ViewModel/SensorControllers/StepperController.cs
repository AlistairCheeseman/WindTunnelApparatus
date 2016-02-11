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
    /// <summary>
    /// This class controls the stepper motor.
    /// it sends the relevant commands to the stepper controller and handles anystuff like that
    /// </summary>
    public class StepperController
    {
        SerialPort SP;
        Dispatcher dispatcher;
        /// <summary>
        /// Initialise the stepper controller class.
        /// </summary>
        /// <param name="ComPort">we need to know the COM port that the controller is connected to.</param>
        public StepperController( Dispatcher dis)
        {
            //create the serial port
            SP = new SerialPort();
            SP.BaudRate = 9600;
            
            isConnected = false; // set the connection to not connected
            SP.DtrEnable = true; // make the device reset on connect.
            dispatcher = dis; // assign the worker process
        }

        public void Connect(string ComPort)
        {
            try
            {
                SP.PortName = ComPort;
                SP.Open();
                // let some data gather before we add the event handler
                System.Threading.Tasks.Task.Delay(5000);
                SP.DataReceived += SP_DataReceived; // create the data receive trigger
                if (SP.IsOpen == true)
                    isConnected = true;
            }
            catch (Exception)
            {
                isConnected = false;
            }
        }

        public void Disconnect()
        {
            SP.DataReceived -= SP_DataReceived;
            SP.Close();
            SP = null;
            isConnected = false;
        }
        public bool isConnected
        { get; set; } = false;
        // is a command being executed?
        public bool isBusy { get; set; }


        private void SP_DataReceived(object sender, SerialDataReceivedEventArgs e)
        {
            byte[] buffer = new byte[265];
            ((SerialPort)sender).Read(buffer, 0, ((SerialPort)sender).BytesToRead);

            this.dispatcher.BeginInvoke(new MyDelegate(ProcessData), DispatcherPriority.Normal, buffer);
        }
        public delegate void MyDelegate(byte[] inData);
        string command = string.Empty;
        public void ProcessData(byte[] inData)
        {
            // this routine has to sort the data into new lines.
            foreach (byte t in inData)
            {
                if (t != 0)
                {
                    command += ((char)t).ToString();
                    if (((char)t).ToString() == "\n")
                    {
                        processStatusMessage();
                    }
                }
            }
        }

        public void processStatusMessage()
        {
            Console.WriteLine(command);
            if (command == "HELLO, PLEASE ENTER CONFIG SETTINGS: MINDELAY (=1) MAXDELAY (=10)\r\n")
            {
                SP.WriteLine("2500 65535"); // give the max speed delay and the min speed delay
            }
            else if (command == "OK WAIT\r\n" || command == "ZEROING ALL AXES\r\n")
            {

            }
            else if (command == "OK READY\r\n")
            { // it is ready send the first command, we will start with a simple movement to the center.
                byte[] command = new byte[9];
                command[0] = 0x01; // x axis motor
                command[1] = 0x01; // half step
                command[2] = 0x03;// FAST
                command[3] = 0x02; //left turn
                command[4] = 0x00;
                command[5] = 0x64; // rotate 100 times.
                command[6] = 0x00;
                command[7] = (byte)'\r';
                command[8] = (byte)'\n';
                SP.Write(command, 0, 9);
                isBusy = true;
            }
            else if (command == "OK DONE\r\n")
            {
                isBusy = false; // we are not busy anymore.

                sendCommand(MotorAxis.x, MotorDirection.left, MotorSpeed.fast, MotorStep.wave, 50, 10, 5);

            }
            command = string.Empty;
        }

        public void sendCommand(MotorAxis xy, MotorDirection dir, MotorSpeed speed, MotorStep step, int rotations, int steps, int holdTime)
        {
            byte[] command = new byte[9];
            command[0] = byte.Parse(Convert.ToInt32(xy).ToString()); // x axis motor
            command[1] = 0x01; // half step
            command[2] = 0x03;// FAST
            command[3] = 0x2; //left turn
            command[4] = 0x00;
            command[5] = 0x0F;
            command[6] = 0x01;
            command[7] = (byte)'\r';
            command[8] = (byte)'\n';
            SP.Write(command, 0, 9);
        }

    }
}
