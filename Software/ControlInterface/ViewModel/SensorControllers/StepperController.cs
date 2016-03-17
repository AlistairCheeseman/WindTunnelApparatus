﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.IO.Ports;
using System.Windows.Threading;
using Model;
using System.ComponentModel;
using ViewModel.Helpers;

namespace ViewModel.SensorControllers
{
    /// <summary>
    /// This class controls the stepper motor.
    /// it sends the relevant commands to the stepper controller and handles anystuff like that
    /// </summary>
    public class StepperController : ViewModelBase
    {
        const int StepsPerRevolution = 200;
        const double pitch = 1;
        const double stepResolution = pitch / StepsPerRevolution;


        SerialPort SP;
        BackgroundWorker BgWorker = new BackgroundWorker();
        /// <summary>
        /// Initialise the stepper controller class.
        /// </summary>
        /// <param name="ComPort">we need to know the COM port that the controller is connected to.</param>
        public StepperController()
        {
            //create the serial port
            SP = new SerialPort();
            SP.BaudRate = 9600;
            isConnected = false; // set the connection to not connected
            SP.DtrEnable = true; // make the device reset on connect.
            BgWorker.DoWork += BgWorker_DoWork;
        }
        // variable ONLY for use by the background worker.
        string thisCommand = string.Empty;
        private void BgWorker_DoWork(object sender, DoWorkEventArgs e)
        {
            while (commands.Count() > 0)
            {
                byte[] inData = commands.Dequeue();
                // this routine has to sort the data into new lines.
                foreach (byte t in inData)
                {
                    Console.Write((char)t);
                    thisCommand += ((char)t).ToString();
                    if (((char)t).ToString() == "\n")
                    {
                        processCommand(thisCommand);
                        thisCommand = String.Empty;
                    }
                }
            }
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
            isConnected = false;
        }


        private ConnectionState _ConnectionState = ConnectionState.Disconnected;
        public ConnectionState ConnectionState
        {
            get
            {
                return _ConnectionState;
            }
            set
            {
                this.SetField(ref _ConnectionState, value, () => ConnectionState);
            }
        }
        private bool _isConnected = false;
        public bool isConnected
        {
            get
            {
                return _isConnected;
            }
            set
            {
                if (value == true)
                {
                    ConnectionState &= ~ConnectionState.Disconnected;
                    ConnectionState = ConnectionState | ConnectionState.Connected; // add the connected status.
                }
                else
                    ConnectionState = ConnectionState.Disconnected; // set the enum to this state solely.
                this.SetField(ref _isConnected, value, () => isConnected);
            }
        }
        // is a command being executed?
        private bool _isBusy = false;
        public bool isBusy
        {
            get
            {
                return _isBusy;
            }
            set
            {
                if (value == true)
                {
                    ConnectionState = ConnectionState | ConnectionState.Busy; // add the connected status.
                }
                else
                    ConnectionState &= ~ConnectionState.Busy;
                this.SetField(ref _isBusy, value, () => isBusy);
            }
        }
        #region position information
        private double _xPosition = 0;
        public double xPosition
        {
            get
            {
                return _xPosition;
            }
            private set // only let this class update the position
            {
                this.SetField(ref _xPosition, value, () => xPosition);
            }
        }
        private double _yPosition = 0;
        public double yPosition
        {
            get
            {
                return _yPosition;
            }
            private set // only let this class update the position
            {
                this.SetField(ref _yPosition, value, () => yPosition);
            }
        }
        #endregion
        Queue<byte[]> commands = new Queue<byte[]>(); // fifo buffer.
        private void SP_DataReceived(object sender, SerialDataReceivedEventArgs e)
        {
            int ByteCount = ((SerialPort)sender).BytesToRead;
            byte[] buffer = new byte[ByteCount];
            ((SerialPort)sender).Read(buffer, 0, ByteCount);
            commands.Enqueue(buffer);
            if (BgWorker.IsBusy == false)
                BgWorker.RunWorkerAsync(); // if the background worker has finished, give it a kick to start up again.
        }


        public bool gotoHorizontal(double Horizontalmm)
        {
            MotorDirection dir = MotorDirection.none;
            if (this.isBusy == true)
                return false;// CANNOT MOVE AS MOTOR BUSY!
            else
            {
                // get current position and calculate the number of steps needed to move.
                double difference = Math.Abs(xPosition - Horizontalmm); // find the mm difference.
                // find the direction
                if (xPosition > Horizontalmm)
                    dir = MotorDirection.left;
                else
                    dir = MotorDirection.right;

                ushort Revs = (ushort)Math.Truncate(difference); // get the number of whole mm difference
                byte steps = (byte)((difference - (double)Revs) / stepResolution); // get fraction of mm and divide by step resolution
                sendCommand(MotorAxis.x, MotorStep.half, MotorSpeed.dynamic, dir, Revs, (byte)steps, 1);
                return true;
            }
        }
        public bool gotoVertical(double Verticalmm)
        {
            MotorDirection dir = MotorDirection.none;
            if (this.isBusy == true)
                return false;// CANNOT MOVE AS MOTOR BUSY!
            else
            {
                // get current position and calculate the number of steps needed to move.
                double difference = Math.Abs(yPosition - Verticalmm); // find the mm difference.
                // find the direction
                if (xPosition > Verticalmm)
                    dir = MotorDirection.left;
                else
                    dir = MotorDirection.right;

                ushort Revs = (ushort)Math.Truncate(difference); // get the number of whole mm difference
                byte steps = (byte)((difference - (double)Revs) / stepResolution); // get fraction of mm and divide by step resolution
                sendCommand(MotorAxis.y, MotorStep.half, MotorSpeed.dynamic, dir, Revs, (byte)steps, 1);
                return true;
            }
        }



        public void processCommand(string command)
        {
            Console.WriteLine("Command Processing: " + command);
            if (command == "XL\r\n" || command == "XR\r\n")
            {
                if (command.Contains("L"))
                    xPosition = xPosition - stepResolution;
                else
                    xPosition = xPosition + stepResolution;
            }
            else if (command == "YL\r\n" || command == "YR\r\n")
            {
                if (command.Contains("L"))
                    yPosition = yPosition - stepResolution;
                else
                    yPosition = yPosition + stepResolution;
            }
            else if (command == "STEPPER V1. ENTER CONFIG\r\n")
            {
                SP.Write("2 65\r\n"); // give the max speed delay and the min speed delay
            }
            else if (command == "ZEROING ALL AXES\r\n")
            {
                xPosition = 0;
                yPosition = 0;
            }
            else if (command == "OK WAIT\r\n")
            {
                sendCommand(MotorAxis.x, MotorStep.half, MotorSpeed.fast, MotorDirection.left, 6, 0, 0);
            }
            else if (command == "OK DONE\r\n")
            {
                isBusy = false; // we are not busy anymore.
            }
        }

        public void sendCommand(MotorAxis xy, MotorStep stepMode, MotorSpeed speed, MotorDirection dir, ushort rotations, byte steps, byte holdTime)
        {
            byte[] command = new byte[10];
            command[0] = byte.Parse(Convert.ToInt32(xy).ToString()); // MOTOR
            command[1] = byte.Parse(Convert.ToInt32(stepMode).ToString()); // STEPMODE
            command[2] = byte.Parse(Convert.ToInt32(speed).ToString());// SPEED
            command[3] = byte.Parse(Convert.ToInt32(dir).ToString()); // DIRECTION
            command[4] = (byte)((rotations & (ushort)0xFF00) >> 8); //MSByte of rotation count
            command[5] = (byte)(rotations & (ushort)0x00FF); // LSByte of rotation count
            command[6] = steps; // number of steps
            command[7] = holdTime; // how long to hold after the command.
            command[8] = (byte)'\r';
            command[9] = (byte)'\n';
            SP.Write(command, 0, 10);
            isBusy = true;
        }

    }
}
