using System;
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
        const int StepsPerRevolution = 200; // number of steps per resolution
        const double pitchum = 1000; // the pitch of the threaded rod.
        const long stepResolutionum = (long) pitchum / StepsPerRevolution; // the distance the float moves per step of the motor
        const bool hasPosnFeedBack = false; // if the stepper gives posn feedback.

        // the zero position when a limit switch is triggered.
        const long ZeroPosnX = 00000; 
        const long ZeroPosnY = 00000;

        const string minDelay = "2.5";// the delay when the motor is running at its fastest speed
        const string maxDelay = "5"; // the delay when the motor is running at its slowest speed

        //what direction the motors need to move in to get to the zero/limit position
        string ZeroXDir = Convert.ToInt32(MotorDirection.left).ToString(); 
        string ZeroYDir = Convert.ToInt32(MotorDirection.right).ToString();

        SerialPort SP; // serial port for comms
        BackgroundWorker BgWorker = new BackgroundWorker(); // the background worker to process the data.
        /// <summary>
        /// Initialise the stepper controller class.
        /// </summary>
        /// <param name="ComPort">we need to know the COM port that the controller is connected to.</param>
        public StepperController()
        {
            //create the serial port
            SP = new SerialPort();
            SP.BaudRate = 76800; // set the baud rate
            isConnected = false; // set the connection to not connected
            SP.DtrEnable = true; // make the device reset on connect.
            BgWorker.DoWork += BgWorker_DoWork; // tell the background worker what task it has to do.
        }
        // variable ONLY for use by the background worker.
        string thisCommand = string.Empty;
        private void BgWorker_DoWork(object sender, DoWorkEventArgs e)
        {
            while (commands.Count() > 0) // if there are commands pending
            {
                byte[] inData = commands.Dequeue(); //get the commands
                // this routine has to sort the data into new lines.
                foreach (byte t in inData) // for each byte
                {
                   // Console.Write((char)t);
                    thisCommand += ((char)t).ToString(); // add it to the pending command string
                    if (((char)t).ToString() == "\n") // if it is a new line 
                    {
                        processCommand(thisCommand); // tell the worker to process the command
                        thisCommand = String.Empty; // reset the container
                    }
                }
            }
        }

        public void Connect(string ComPort)
        {
            try
            {
                SP.PortName = ComPort; // set the com port
                SP.Open(); // open the serial port
                // let some data gather before we add the event handler
                System.Threading.Tasks.Task.Delay(5000);
                SP.DataReceived += SP_DataReceived; // create the data receive trigger
                if (SP.IsOpen == true) // check it connected 
                    isConnected = true;
            }
            catch (Exception)
            {
                isConnected = false;
            }
        }

        public void Disconnect()
        {// disconnect from the stepper controller
            SP.DataReceived -= SP_DataReceived; // remove the event handler
            SP.Close(); // close the serial port
            isConnected = false; // set the disconnected flag.
        }

        //property for the connection state
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
        //property to show connection flag.
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
        // mm from origin in x axis.
        public double xPositionmm
        {
            get
            {
                //derive the location from the um reading
                return _xPositionum / 1000.0;
            }

        }
        // mm from origin in y axis.
        public double yPositionmm
        {
            get
            {
                //derive the location from the um reading
                return _yPositionum / 1000.0;
            }

        }
        // micrometers from the origin in the y.
        private long _yPositionum = 0;
        public long yPositionum
        {
            get
            {
                return _yPositionum;
            }
            private set
            {
                this.SetField(ref _yPositionum, value, () => yPositionum);  // update value using helper
                this.OnPropertyChanged("yPositionmm"); //notify a property has changed.
            }
        }
        // micrometers from the origin in the y.
        public long _xPositionum = 0;
        public long xPositionum
        {
            get
            {
                return _xPositionum;
            }
            private set
            {
                this.SetField(ref _xPositionum, value, () => xPositionum); //update value using helper
                this.OnPropertyChanged("xPositionmm");//notify a property has changed.
            }
        }
        #endregion
        Queue<byte[]> commands = new Queue<byte[]>(); // fifo buffer of commands
        private void SP_DataReceived(object sender, SerialDataReceivedEventArgs e)
        {
            int ByteCount = ((SerialPort)sender).BytesToRead; // number of bytes to read
            byte[] buffer = new byte[ByteCount]; // container for the data
            ((SerialPort)sender).Read(buffer, 0, ByteCount); // get the data.
            commands.Enqueue(buffer); // enqueue the data to be processed by the worker
            if (BgWorker.IsBusy == false) // check the worker is running
                BgWorker.RunWorkerAsync(); // if the background worker has finished, give it a kick to start up again.
        }


        public bool gotoHorizontal(long Horizontalum)
        {
            MotorDirection dir = MotorDirection.none;
            if (this.isBusy == true)
                return false;// CANNOT MOVE AS MOTOR BUSY!
            else
            {
                // get current position and calculate the number of steps needed to move.
                double difference = Math.Abs(xPositionum - Horizontalum) / 1000.0; // find the mm difference to move
                // find the direction we need to move in
                if (xPositionum > Horizontalum)
                    dir = MotorDirection.left;
                else
                    dir = MotorDirection.right;

                ushort Revs = (ushort)Math.Truncate(difference); // get the number of whole mm difference
                byte steps = (byte)((difference - (double)Revs) / (stepResolutionum/1000.0)); // get fraction of mm and divide by step resolution
                sendCommand(MotorAxis.x, MotorStep.half, MotorSpeed.dynamic, dir, Revs, (byte)steps, 1); // actually send the command
                return true;
            }
        }
        public bool gotoVertical(long Verticalum)
        {
            MotorDirection dir = MotorDirection.none;
            if (this.isBusy == true)
                return false;// CANNOT MOVE AS MOTOR BUSY!
            else
            {
                // get current position and calculate the number of steps needed to move.
                double difference = Math.Abs(yPositionum - Verticalum) / 1000.0; // find the mm difference.
                // find the direction we need to move in
                if (yPositionum > Verticalum)
                    dir = MotorDirection.right;
                else
                    dir = MotorDirection.left;

                ushort Revs = (ushort)Math.Truncate(difference); // get the number of whole mm difference
                byte steps = (byte)((difference - (double)Revs) / (stepResolutionum / 1000.0)); // get fraction of mm and divide by step resolution
                sendCommand(MotorAxis.y, MotorStep.half, MotorSpeed.dynamic, dir, Revs, (byte)steps, 1);// actually send the command
                return true;
            }
        }



        public void processCommand(string command)
        {// this routine processes any received infomation from the controller.
        //    Console.WriteLine("Command Processing: " + command);
            if (command == "XL\r\n" || command == "XR\r\n") // x axis position update
            {
                if (command.Contains("L")) // left or right?
                    xPositionum = xPositionum - stepResolutionum; // update posn value
                else
                    xPositionum = xPositionum + stepResolutionum;// update posn value
            }
            else if (command == "YL\r\n" || command == "YR\r\n")// y axis position update
            {
                if (command.Contains("L"))// left or right?
                    yPositionum = yPositionum + stepResolutionum;// update posn value
                else
                    yPositionum = yPositionum - stepResolutionum;// update posn value
            }
            else if (command == "STEPPER V1. ENTER CONFIG\r\n") // the sensor has just updated.
            {
                //send the control variables to the controller.
                //slow speed fast speed dirx diry
                SP.Write(minDelay + " " + maxDelay + " " + ZeroXDir+" " + ZeroYDir + "\r\n"); // give the max speed delay and the min speed delay
            }
            else if (command == "ZEROED\r\n") // the motors have just zeroed.
            {
                //update the positions to the zero value
                xPositionum = ZeroPosnX;
                yPositionum = ZeroPosnY;
            }
            else if (command == "OK WAIT\r\n") // this command is sent after a zero, initialise the controller to operate mode with a zero position move.
            {
                sendCommand(MotorAxis.x, MotorStep.half, MotorSpeed.fast, MotorDirection.left, 0, 0, 0);
            }
            else if (command == "OK DONE\r\n") // the controller has just finished the movement
            {
                isBusy = false; // we are not busy anymore.
            }
        }

        public void sendCommand(MotorAxis xy, MotorStep stepMode, MotorSpeed speed, MotorDirection dir, ushort rotations, byte steps, byte holdTime)
        {
            //this routine constructs the commands to be sent to the motor using the enum class.
            byte[] command = new byte[10]; // allocate the data to be populated
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
            SP.Write(command, 0, 10); // send the command down the serial line.
            isBusy = true; // set the controller to the busy state.
        }

    }
}
