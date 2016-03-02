using System;
using System.Collections.Generic;
using System.Collections.Concurrent;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.IO.Ports;
using System.Windows.Threading;
using Model;
using ViewModel.Helpers;
using System.ComponentModel;

namespace ViewModel.SensorControllers
{
    public class PressureController : ViewModelBase
    {
        SerialPort SP;
        System.IO.FileStream FS = null;
        Random RandomGenerator = new Random(); // random number generator - for delays.
        TimeSpan TTR = new TimeSpan(21230); // TIME TO READ  - delay between readings. The system clock is no accurate enough to mark each reading, so it must be calculated by a known time that the fpga takes to process.
        DateTime? FirstReading = null; // When the readings have started.
        DateTime? LastReading = null;
        //Background workers
        BackgroundWorker SerialWorker = new BackgroundWorker();
        BackgroundWorker DataProcessor = new BackgroundWorker();
        /// <summary>
        ///  class to hold raw timestamped data.
        /// </summary>
        // buffer between SerialWorker and DataProcessor.
        ConcurrentQueue<Byte> RawQueue = new ConcurrentQueue<Byte>(); // a threadsafe queue of data to be processed.
        public PressureController()
        {
            SP = new SerialPort(); // create the serial port.
            SP.BaudRate = 2000000; // the baud rate of the FPGA
            SP.ReadBufferSize = 2147483646; //the max buffer size so we don't slow down the FPGA.
            isConnected = false; // default to not connected.
            SerialWorker.DoWork += BWReadSerial; // assign the serial reader function
            DataProcessor.DoWork += BWDataProcessor; // assign the data reader process
        }
        #region Data container + helpers
        List<PressureData> OutputData = new List<PressureData>();
        public decimal CurrentSensor1Reading
        { get; private set; } = 0;
        public decimal CurrentSensor2Reading
        { get; private set; } = 0;
        public decimal CurrentSensor3Reading
        { get; private set; } = 0;
        public decimal CurrentSensor4Reading
        { get; private set; } = 0;
        public decimal CurrentSensor5Reading
        { get; private set; } = 0;
        public decimal CurrentSensor6Reading
        { get; private set; } = 0;
        public decimal CurrentSensor7Reading
        { get; private set; } = 0;
        public decimal CurrentSensor8Reading
        { get; private set; } = 0;
        public decimal CurrentSensor9Reading
        { get; private set; } = 0;
        public decimal CurrentSensor10Reading
        { get; private set; } = 0;
        // data class for the graph to look at.
        public List<PressureData> GraphData
        {
            get
            {
                return OutputData.ToList();
            }
        }
        #endregion
        #region Connection Information
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
        #endregion

        #region Background Workers
        long ReadingCount = 0; // counter for number of readings

        private void BWDataProcessor(object sender, DoWorkEventArgs e)
        {
            while (RawQueue.Count > 6) // while there is enough data to be able to process a payload. ( a bit of wiggle room incase of a bad packet.
            {
                byte[] currentPacket = new byte[12];
                int currentByteIndex = 0;
                bool finishFlag = false; // if true quit the loop
                while (finishFlag == false)
                {
                    Byte record = 0x00;
                    if (RawQueue.TryPeek(out record) == true)
                    { // we could peek the record, see what it looks like
                        if (record == 0x00 && currentByteIndex >= 5)
                        {
                            //BOOM end of record!
                            finishFlag = true;
                            continue;
                        }
                        else
                        {
                            // it is just another record, 
                            bool gotRecord = false;
                            while (gotRecord == false)
                            {
                                if (RawQueue.TryDequeue(out record) == true)
                                {
                                    currentPacket[currentByteIndex] = record;
                                    currentByteIndex++;
                                    gotRecord = true; // we have the record!
                                    continue; // exit the loop
                                }
                                else
                                {
                                    // we couldn't dequeue the record!!!!!!!!.
                                    System.Threading.Thread.Sleep(RandomGenerator.Next()); // sleep a random amount of time before retrying.
                                }
                            }
                        }
                    }
                    else
                    {
                        System.Threading.Thread.Sleep(RandomGenerator.Next()); // sleep a random amount of time before retrying.
                    }
                }


                // finally get the delimiter record with its timestamp value, so we need to get the full record, not just the data.
                byte delimeter = 0x00;
                bool gotDelimeterRecord = false;
                while (gotDelimeterRecord == false)
                {
                    if (RawQueue.TryDequeue(out delimeter) == true)
                    {
                        gotDelimeterRecord = true; // we have the record!
                        continue; // exit the loop
                    }
                    else
                    {
                        // we couldn't dequeue the record!!!!!!!!.
                        System.Threading.Thread.Sleep(RandomGenerator.Next()); // sleep a random amount of time before retrying.
                    }
                }

                if (delimeter != 0x00)
                {
                    Console.WriteLine("Woah, lost sync!");// somehow we have lost sync?!???!!
                    continue; // we need to recover from this.
                }

                if (currentByteIndex > 5)
                {
                    Console.WriteLine("Too much data between delimeters, this is expected for the 1st value returned.");
                    continue; // way too much data between delimeters, skip this data.
                }
                else if ((currentByteIndex) == 5) // if the sum of the indexes == 5 we have a whole 6 bytes!
                {
                    // we have a whole packet here!
                    ushort rawPressure = (ushort)(((currentPacket[0] & 0x3F) << 8) | currentPacket[1]); // get the actual data and remove any error codes.
                    ushort rawTemperature = (ushort)(((currentPacket[2]) << 8) | currentPacket[3] & 0xE0); // get the temperature data, make sure there isn't any extra crap.
                    rawTemperature = (ushort)(rawTemperature >> 5); // align the temperature correctly, was left aligned, make right aligned.
                    ushort SensorId = (ushort)(currentPacket[4]); // get the sensor Id.
                    ushort ErrorCode = (ushort)(currentPacket[0] & 0xC0); // get the error code. 0 - none, 2 - stale data, 3 - bridge error 1 - device in diagnostic mode.
                    decimal cmH2o = ((rawPressure - 1638.0M) / 655.35M) - 10M;
                    decimal Pa = cmH2o * 98.0665M;


                    
                    if (ReadingCount == 0 | LastReading == null)
                    {
                        LastReading = FirstReading.Value; // it is the 1st reading, don't increment.
                    }
                    else if (SensorId ==1)
                    {
                        // it is the start of a new batch of readings.
                        LastReading = LastReading.Value + TTR;
                    }




                    //temp range = 2048 - 0 == -5 to +65
                    decimal Temperature = ((decimal)rawTemperature * (70.0M / 2048.0M)) - 5.0M;

                    // this is just for timing checking to see if sync roughly matches up:
                    double jitter = (DateTime.Now - LastReading.Value).TotalMilliseconds;
                    if (jitter > 100 || jitter < -100)
                        Console.WriteLine("TIME SYNC LOST: {0}", jitter);


                    OutputData.Add(new PressureData(ReadingCount, Pa, Temperature, ErrorCode, SensorId, LastReading.Value));
                    ReadingCount++;
                    this.CurrentSensor1Reading = Pa;
                }
                else
                    Console.WriteLine("ERROR BAD PACKET");
            }
        }
        // this process is designed to be very quick and lightweight. The heavy lifting is done by the data processor.
        private void BWReadSerial(object sender, DoWorkEventArgs e)
        {
            bool finishFlag = false;

            while (finishFlag == false)
            {
                if (SP.IsOpen == false)
                {
                    finishFlag = true;
                    this.isConnected = false;
                    break; // close the worker down.
                }
                int bytes = SP.BytesToRead;
                if (bytes == 0x00)
                {
                    System.Threading.Thread.Sleep(100); // sleep and wait for data.
                    continue; // move to next loop.
                }
                byte[] data = new byte[bytes];
                SP.Read(data, 0, bytes);
                for (int p = 0; p < bytes; p++)
                {// for each byte received.
                    if (FirstReading == null)
                        FirstReading = (DateTime.Now);

                    ////   RawQueue.Enqueue(data[p]);
                        Console.Write(data[p].ToString("X2") + "-");
                    if (data[p] == 0x00)
                        Console.WriteLine();
                    // also write the data to a file:
                    if (FS != null)
                        FS.WriteByte(data[p]);
                }
                // if the data processor is not working, give it a kick.
 
            //        if (DataProcessor.IsBusy == false)
        //            DataProcessor.RunWorkerAsync();
            }
        }
        #endregion
        #region Functions called by other classes
        public void Connect(string ComPort)
        {
            try
            {
                SP.PortName = ComPort;
                SP.Open();
                FS = System.IO.File.OpenWrite("PressureLog" + DateTime.Now.ToString("yyyy-MM-dd HH-mm-ss") + ".dat");
                // let some data gather before we add the event handler

                if (SP.IsOpen == true)
                {
                    isConnected = true;
                    SerialWorker.RunWorkerAsync();
                }
                else
                {
                    isConnected = false;
                    Console.WriteLine("Could not open serial port.");
                }

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
            SP.Close();
            isConnected = false;
            FS.Close();
            FS = null;
            FirstReading = null;
        }
        public void ExportNiceData(string FilePath)
        {
            IOrderedEnumerable<PressureData> ExportList = OutputData.OrderBy(x => x.id); // export ordered Data.
            StringBuilder SB = new StringBuilder();
            SB.Append("id, Time, Sensor, Value(Pa), Temperature(°C)\r\n");
            foreach (PressureData data in ExportList)
            {
                SB.AppendFormat("{0}, {1:H:mm:ss.fffff}, {2}, {3}, {4}\r\n", data.id, data.moment, data.sensorId, data.Pressure, data.Temperature);
            }
            System.IO.File.WriteAllText(FilePath, SB.ToString());
        }
        public void TriggerUIUpdate()
        {
            // trigger a sensor status update.
            this.OnPropertyChanged("CurrentSensor1Reading");
            this.OnPropertyChanged("CurrentSensor2Reading");
            this.OnPropertyChanged("CurrentSensor3Reading");
            this.OnPropertyChanged("CurrentSensor4Reading");
            this.OnPropertyChanged("CurrentSensor5Reading");
            this.OnPropertyChanged("CurrentSensor6Reading");
            this.OnPropertyChanged("CurrentSensor7Reading");
            this.OnPropertyChanged("CurrentSensor8Reading");
            this.OnPropertyChanged("CurrentSensor9Reading");
            this.OnPropertyChanged("CurrentSensor10Reading");
            this.OnPropertyChanged("GraphData");
        }

        public void ClearBuffer()
        {
            if (SP.IsOpen == true)
            {
                SP.DiscardInBuffer();
                LastReading = null;

                FirstReading = DateTime.Now;
            }
        }
        #endregion
    }

}

