﻿using System;
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
        BackgroundWorker DataSerialiser = new BackgroundWorker();
        BackgroundWorker DataProcessor = new BackgroundWorker();
        // buffer between SerialWorker and DataProcessor.
        BlockingCollection<byte[]> ArrayQueue = new BlockingCollection<byte[]>(); // a thread-safe queue of serial array data to be processed.
        BlockingCollection<byte[]> PacketQueue = new BlockingCollection<byte[]>(); // a queue of packets. 
        public PressureController()
        {
            SP = new SerialPort(); // create the serial port.
            SP.BaudRate = 2000000; // the baud rate of the FPGA
            SP.ReadBufferSize = 2147483646; //the Max buffer size so we don't slow down the FPGA.
            isConnected = false; // default to not connected.
            SerialWorker.DoWork += BWReadSerial; // assign the serial reader function
            SerialWorker.WorkerSupportsCancellation = true;
            DataSerialiser.DoWork += BWSerialiser; // assign the data serialiser.
            DataProcessor.DoWork += BWDataProcessor; // assign the data reader process
        }

        #region Data container + helpers
        public List<PressureData> OutputData { get; set; } = new List<PressureData>();
        public bool RecordData = false;
        public double CurrentSensor1Reading
        { get; private set; } = 0;
        public double CurrentSensor2Reading
        { get; private set; } = 0;
        public double CurrentSensor3Reading
        { get; private set; } = 0;
        public double CurrentSensor4Reading
        { get; private set; } = 0;
        public double CurrentSensor5Reading
        { get; private set; } = 0;
        public double CurrentSensor6Reading
        { get; private set; } = 0;
        public double CurrentSensor7Reading
        { get; private set; } = 0;
        public double CurrentSensor8Reading
        { get; private set; } = 0;
        public double CurrentSensor9Reading
        { get; private set; } = 0;
        public double CurrentSensor10Reading
        { get; private set; } = 0;

        #endregion
        #region Connection Information
        private int _SerialQueueCount = 0;
        public int SerialQueueCount
        {
            get
            {
                return _SerialQueueCount;
            }
            private set
            {
                _SerialQueueCount = value;
            }
        }
        private int _BytesQueueCount = 0;
        public int BytesQueueCount
        {
            get
            {
                return _BytesQueueCount;
            }
            private set
            {
                _BytesQueueCount = value;
            }
        }
        private int _PacketQueueCount = 0;
        public int PacketQueueCount
        {
            get
            {
                return _PacketQueueCount;
            }
            private set
            {
                _PacketQueueCount = value;
            }
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
        #endregion

        #region Background Workers
        long ReadingCount = 0; // counter for number of readings
        // this process is designed to be very quick and lightweight. The heavy lifting is done by the data processor.
        // this process reads serial data as quick as possible and passes off to BWSserialiser
        private void BWReadSerial(object sender, DoWorkEventArgs e)
        {
            bool finishFlag = false;
            while (finishFlag == false && e.Cancel == false)
            {
                if (SP != null && SP.IsOpen == false)
                {
                    finishFlag = true;
                    this.isConnected = false;
                    break; // close the worker down.
                }
                SerialQueueCount = SP.BytesToRead;
                if (FirstReading == null)
                    FirstReading = (DateTime.Now);
                
                int bytes = SP.BytesToRead;
                if (bytes == 0x00)
                {
                    System.Threading.Thread.Sleep(100); // sleep and wait for data.
                    continue; // move to next loop.
                }
                else if (bytes > System.Int32.MaxValue) // catch a too big buffer.
                    bytes = System.Int32.MaxValue;
                byte[] data = new byte[bytes];
                SP.Read(data, 0, bytes);
                bool hasAdded = false;
                while (hasAdded == false)
                {
                    hasAdded = ArrayQueue.TryAdd(data);
                    if (hasAdded == false)
                        System.Threading.Thread.Sleep(new TimeSpan(100)); // wait 10 uS
                }
                // if the data processor is not working, give it a kick.
                if (DataSerialiser.IsBusy == false)
                    DataSerialiser.RunWorkerAsync();
                // write the data to the raw file.
                if (FS != null)
                    FS.WriteAsync(data, 0, bytes);  
            }
        }
        // this takes byte arrays and serialises them into a potential packet this makes the actual processing quicker and easier.
        private void BWSerialiser(object sender, DoWorkEventArgs e)
        {
            byte lastrecord = 0x00;
            byte[] currentPacket = new byte[8000]; // a nice big buffer in case the data has become mangled.
            int dataIndex = 0; // pointer to hold the index to the array
            foreach (var item in ArrayQueue.GetConsumingEnumerable()) // this gets each item, blocking if there is not any data, quits when CompleteAdding() is finished.
            {
                byte[] dataIn = item;
                int count = dataIn.Count();
                for (int record = 0; record < count; record++)
                {
                    currentPacket[dataIndex] = dataIn[record];
                    if (dataIndex != 0)
                    lastrecord = currentPacket[dataIndex - 1]; 

                    dataIndex++;
                    if (dataIn[record] == 0xFF && lastrecord == 0x00)// commented out to try and keep sync. && dataIndex > 61) // check we have at least a full packet.
                    {
                        byte[] dataOut = new byte[dataIndex];
                        Buffer.BlockCopy(currentPacket, 0, dataOut, 0, dataIndex);
                        bool hasAdded = false;
                        while (hasAdded == false)
                        {
                           hasAdded = PacketQueue.TryAdd(dataOut);
                            if (hasAdded == false)
                                System.Threading.Thread.Sleep(new TimeSpan(100)); // wait 10 uS
                        }
                        dataIndex = 0;
                    }
                }
                // if the data processor is not working, give it a kick.
                if (DataProcessor.IsBusy == false)
                    DataProcessor.RunWorkerAsync();

                BytesQueueCount = ArrayQueue.Count();
            }
            PacketQueue.CompleteAdding(); // we have finished processing, make sure the data processor is aware that we have finished adding.
        }
        // this actually process the data and gives the sensor readings.
        private void BWDataProcessor(object sender, DoWorkEventArgs e)
        {
            foreach (var item in PacketQueue.GetConsumingEnumerable())
            {
                if (LastReading == null | ReadingCount == 0) // if there hasn't been a reading.
                    LastReading = FirstReading.Value;  // set the time stamp value for this data set.
                // Console.WriteLine(BitConverter.ToString(item));
                PacketQueueCount = PacketQueue.Count();
                int SensorCount = 0;
                int remainder = 0;
                SensorCount = System.Math.DivRem(item.Count() - 1, 6, out remainder);
                if (item.Count() <= 6)
                {// the packet is too small.
                    Console.WriteLine("ERROR: PACKET TOO SMALL.");
                    continue;
                } else if (item.Count() > 61)
                {
                    Console.WriteLine("ERROR PACKET TOO LARGE");
                    continue;
                }
                else if (SensorCount == 0 | SensorCount > 10)
                {
                    Console.WriteLine("ERROR BAD SIZE PACKET");
                    continue;
                }
                else
                {
                    //good packet.
                    for ( int packetCount = 0; packetCount < SensorCount; packetCount++)
                    {
                        ushort rawPressure = (ushort)(((item[0 + (packetCount * 6)] & 0x3F) << 8) | item[1 + (packetCount * 6)]); // get the actual data and remove any error codes.
                       
                        ushort rawTemperature = (ushort)(((item[2 + (packetCount * 6)]) << 8) | item[3 + (packetCount * 6)] & 0xE0); // get the temperature data, make sure there isn't any extra crap.
                        rawTemperature = (ushort)(rawTemperature >> 5); // align the temperature correctly, was left aligned, make right aligned.
                        ushort SensorId = (ushort)(item[4 + (packetCount * 6)]); // get the sensor Id.
                        ushort ErrorCode = (ushort)(item[0 + (packetCount * 6)] & 0xC0); // get the error code. 0 - none, 2 - stale data, 3 - bridge error 1 - device in diagnostic mode.
                        double cmH2o = ((rawPressure - 1638.0) / 655.35) - 10.0;
                        double Pa = cmH2o * 98.0665;
                        //temp range = 2048 - 0 == -5 to +65
                        double Temperature = (rawTemperature * (70.0 / 2048.0)) - 5.0;

                        if (RecordData == true)
                        {
                            OutputData.Add(new PressureData(ReadingCount, Pa, Temperature, ErrorCode, SensorId, LastReading.Value));
                            ReadingCount++;
                        }

                        switch (SensorId)
                        {
                            case 1: CurrentSensor1Reading = Pa; break;
                            case 2: CurrentSensor2Reading = Pa; break;
                            case 3: CurrentSensor3Reading = Pa; break;
                            case 4: CurrentSensor4Reading = Pa; break;
                            case 5: CurrentSensor5Reading = Pa; break;
                            case 6: CurrentSensor6Reading = Pa; break;
                            case 7: CurrentSensor7Reading = Pa; break;
                            case 8: CurrentSensor8Reading = Pa; break;
                            case 9: CurrentSensor9Reading = Pa; break;
                            case 10: CurrentSensor10Reading = Pa; break;
                        }
                    }
                    if (item[item.Count() - 1] != 0xFF)
                    {
                        Console.WriteLine("LOST PACKET SYNC");
                        continue;

                    }

                }
                LastReading = LastReading + TTR; // update the reading time stamp.
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
                if (SP.IsOpen == true)
                {
                    isConnected = true;
                    SerialWorker.RunWorkerAsync();
                }
                else
                {
                    isConnected = false;
                    Console.WriteLine("Could not open serial port:");
                }
            }
            catch (Exception ex)
            {
                isConnected = false;
                Console.ForegroundColor = ConsoleColor.Red;
                Console.WriteLine("COULD NOT OPEN SERIAL PORT: " + ex.ToString());
                Console.ForegroundColor = ConsoleColor.White;
            }
        }
        public void Disconnect()
        {
            //SP.DiscardInBuffer(); // clear out anything in the serial port receive buffer.
            SerialWorker.CancelAsync();
            SP.Close(); // close the serial port, the serial worker will detect this and shutdown.
            isConnected = false; // set the disconnected flag, this closes down the serial receive worker.
          //  while (SerialWorker.IsBusy == true) // make sure the serial worker has shut down.
          //  { System.Threading.Thread.Sleep(1000); } // wait 1 second for the serial worker to finish what it is doing before closing the log file.
            FS.FlushAsync(); // write any remaining stuff to disk
            FS.Close(); // close the raw log file
            FS = null; // close the handle to the log file
            FirstReading = null; // reset the reading timer.
            ArrayQueue.CompleteAdding(); // lock down the serial queue, causing the serial worker to finish what data is left in the queue.

        }
        public void ExportNiceData(string FilePath)
        {
           StringBuilder SB = new StringBuilder();
            SB.Append("id, Time, Value1(Pa), Temperature1(C), Value2(Pa), Temperature2(C), Value3(Pa), Temperature3(C), Value4(Pa), Temperature4(C), Value5(Pa), Temperature5(C), Value6(Pa), Temperature6(C), Value7(Pa), Temperature7(C), Value8(Pa), Temperature8(C), Value9(Pa), Temperature9(C), Value10(Pa), Temperature10(C)\r\n");
            long PressureCount = 0;
            List<PressureExportData> Exportdata =  getExportData(OutputData, ref PressureCount); 
            foreach (PressureExportData ED in Exportdata)
            {
                SB.AppendFormat("{0}, {1:H:mm:ss.fffff}, {2}, {3}, {4}, {5}, {6}, {7}, {8}, {9}, {10}, {11}, {12}, {13}, {14}, {15}, {16}, {17}, {18}, {19}, {20}, {21}\r\n",
                ED.id, ED.moment,
                ED.Pressure1, ED.Temperature1,
                ED.Pressure2, ED.Temperature2,
                ED.Pressure3, ED.Temperature3,
                ED.Pressure4, ED.Temperature4,
                ED.Pressure5, ED.Temperature5,
                ED.Pressure6, ED.Temperature6,
                ED.Pressure7, ED.Temperature7,
                ED.Pressure8, ED.Temperature8,
                ED.Pressure9, ED.Temperature9,
                ED.Pressure10, ED.Temperature10
                );
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
            this.OnPropertyChanged("SerialQueueCount");
            this.OnPropertyChanged("BytesQueueCount");
            this.OnPropertyChanged("PacketQueueCount");
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






        public static List<PressureExportData> getExportData(List<PressureData> _DataIn, ref long startId)
        {
            List<PressureData> DataList = _DataIn;
         //   DataList.Sort(delegate (PressureData c1, PressureData c2) { return c1.id.CompareTo(c2.id); }); // export ordered Data.
            List<PressureExportData> Exportdata = new List<PressureExportData>();
            PressureExportData record = new PressureExportData();

            int readingCount = DataList.Count();


            for (int reading = 0; reading < readingCount; reading++)
            {
                switch (DataList[reading].sensorId)
                {
                    case 1:
                        if (record != null)
                            Exportdata.Add(record);
                        record = new PressureExportData();
                        record.id = startId;
                        startId++;
                        record.moment = DataList[reading].moment;
                        record.Pressure1 = DataList[reading].Pressure;
                        record.Temperature1 = DataList[reading].Temperature;
                        break;
                    case 2:
                        record.Pressure2 = DataList[reading].Pressure;
                        record.Temperature2 = DataList[reading].Temperature;
                        break;
                    case 3:
                        record.Pressure3 = DataList[reading].Pressure;
                        record.Temperature3 = DataList[reading].Temperature;
                        break;
                    case 4:
                        record.Pressure4 = DataList[reading].Pressure;
                        record.Temperature4 = DataList[reading].Temperature;
                        break;
                    case 5:
                        record.Pressure5 = DataList[reading].Pressure;
                        record.Temperature5 = DataList[reading].Temperature;
                        break;
                    case 6:
                        record.Pressure6 = DataList[reading].Pressure;
                        record.Temperature6 = DataList[reading].Temperature;
                        break;
                    case 7:
                        record.Pressure7 = DataList[reading].Pressure;
                        record.Temperature7 = DataList[reading].Temperature;
                        break;
                    case 8:
                        record.Pressure8 = DataList[reading].Pressure;
                        record.Temperature8 = DataList[reading].Temperature;
                        break;
                    case 9:
                        record.Pressure9 = DataList[reading].Pressure;
                        record.Temperature9 = DataList[reading].Temperature;
                        break;
                    case 10:
                        record.Pressure10 = DataList[reading].Pressure;
                        record.Temperature10 = DataList[reading].Temperature;
                        break;
                }
            }
            if (record != null)
                Exportdata.Add(record);

            return Exportdata;
        }
    }

}

