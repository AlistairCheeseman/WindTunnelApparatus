using System;
using System.Collections.Generic;
using System.Collections.Concurrent;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Model;
using ViewModel.Helpers;
using System.IO.Ports;
using System.IO;
using System.ComponentModel;


namespace ViewModel.SensorControllers
{
    public class HotWireController : ViewModelBase
    {
        #region internal variables
        SerialPort SP;
        FileStream FS = null;
        BackgroundWorker SerialWorker = new BackgroundWorker();
        BackgroundWorker DataDefragmentor = new BackgroundWorker();
        BackgroundWorker DataProcessor = new BackgroundWorker();
        Random RandomGenerator = new Random(); // random number generator - for delays.
        DateTime? FirstReading = null; // When the readings have started.
        DateTime? LastReading = null;
        // buffer between SerialWorker and DataProcessor.
        BlockingCollection<byte[]> ArrayQueue = new BlockingCollection<byte[]>(); // a thread-safe queue of serial array data to be processed.
        BlockingCollection<byte[]> PacketQueue = new BlockingCollection<byte[]>(); // a queue of packets. 
        long ReadingCount = 0; // counter for number of readings
        TimeSpan TTR = new TimeSpan(21230); // TIME TO READ  - delay between readings. The system clock is no accurate enough to mark each reading, so it must be calculated by a known time that the fpga takes to process.
        #endregion
        public HotWireController()
        {
            SP = new SerialPort(); // create the serial port.
            SP.BaudRate = 2000000; // the baud rate of the FPGA
            SP.ReadBufferSize = 2147483646; //the Max buffer size so we don't slow down the FPGA.
            isConnected = false; // default to not connected.
            SerialWorker.DoWork += BWReadSerial; // assign the serial reader function
            SerialWorker.WorkerSupportsCancellation = true;
            DataDefragmentor.DoWork += BWSerialiser; // assign the data serialiser.
            DataProcessor.DoWork += BWDataProcessor; // assign the data reader process
        }



        #region Properties + Data
        public List<HotWireData> OutputData = new List<HotWireData>();
        public double CurrentSensor1Reading
        { get; private set; } = 0;
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
        #endregion
        #region Functions called by other classes
        public void Connect(string ComPort)
        {
            try
            {
                SP.PortName = ComPort;
                SP.Open();
                FS = File.OpenWrite("HotWireLog" + DateTime.Now.ToString("yyyy-MM-dd HH-mm-ss") + ".dat");
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
            SerialWorker.CancelAsync();
            SP.Close(); // close the serial port, the serial worker will detect this and shutdown.
            isConnected = false; // set the disconnected flag, this closes down the serial receive worker.
            FS.FlushAsync(); // write any remaining stuff to disk
            FS.Close(); // close the raw log file
            FS = null; // close the handle to the log file
            FirstReading = null; // reset the reading timer.
            ArrayQueue.CompleteAdding(); // lock down the serial queue, causing the serial worker to finish what data is left in the queue.
        }
        public void Export(string FilePath)
        {
            IOrderedEnumerable<HotWireData> DataList = OutputData.OrderBy(x => x.id); // export ordered Data.
            StringBuilder SB = new StringBuilder();
            SB.Append("id, Time, HotWire1\r\n");
            foreach (HotWireData data in DataList)
            {
                SB.AppendFormat("{0}, {1:H:mm:ss.fffff}, {2}\r\n",
                data.id, data.moment, data.measurement);
            }
            System.IO.File.WriteAllText(FilePath, SB.ToString());
        }
        public void TriggerUIUpdate()
        {
            this.OnPropertyChanged("CurrentSensor1Reading");
            this.OnPropertyChanged("SerialQueueCount");
            this.OnPropertyChanged("BytesQueueCount");
            this.OnPropertyChanged("PacketQueueCount");
        }
        #endregion

        #region BackgroundWorkers
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
                if (DataDefragmentor.IsBusy == false)
                    DataDefragmentor.RunWorkerAsync();
                // write the data to the raw file.
                if (FS != null)
                    FS.WriteAsync(data, 0, bytes);
            }
        }
        // this takes byte arrays and serialises them into a potential packet this makes the actual processing quicker and easier.
        private void BWSerialiser(object sender, DoWorkEventArgs e)
        {
            byte lastrecord = 0x00;
            byte[] currentPacket = new byte[500]; // a nice big buffer in case the data has become mangled.
            int dataIndex = 0; // pointer to hold the index to the array
            foreach (var item in ArrayQueue.GetConsumingEnumerable()) // this gets each item, blocking if there is not any data, quits when CompleteAdding() is finished.
            {
                byte[] dataIn = item;
                int count = dataIn.Count();
                for (int record = 0; record < count; record++)
                {
                    currentPacket[dataIndex] = dataIn[record]; // load a byte into the staging area for a packet.
                    dataIndex++; // increment the current packet index.

                    // detect if it is the end of a packet:
                    if ((dataIn[record] & 0x03) == 0x00 && dataIndex > 0)// commented out to try and keep sync. && dataIndex > 61) // check we have at least a full packet.
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
                if (item.Count() <= 1)
                {// the packet is too small.
                    Console.WriteLine("ERROR: PACKET TOO SMALL.");
                    continue;
                }
                else if (item.Count() > 2)
                {
                    Console.WriteLine("ERROR PACKET TOO LARGE");
                    continue;
                }
                else
                {
                    //good packet.
                    ushort reading = (ushort)(((item[0] << 8) | item[1]) >> 2); // get the actual data and align right.
                    OutputData.Add(new HotWireData(ReadingCount, reading, LastReading.Value));
                    ReadingCount++;
                    CurrentSensor1Reading = reading;
                    if ((item[1] & 0x03) != 0x00)
                    {
                        Console.WriteLine("LOST PACKET SYNC");
                        continue;
                    }
                }
                LastReading = LastReading + TTR; // update the reading time stamp.
            }
        }


        #endregion
    }
}