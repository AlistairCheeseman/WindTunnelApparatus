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
        SerialPort SP;
        Dispatcher dispatcher;
        System.IO.FileStream FS = null;
      List<PressureData> OutputData = new List<PressureData>();


        public bool isConnected
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
                FS = System.IO.File.OpenWrite("PressureLog" + DateTime.Now.ToString("yyyy-MM-dd HH-mm-ss") + ".dat");
                // let some data gather before we add the event handler
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

            SP.DataReceived -= SP_DataReceived;
            SP.Close();
            isConnected = false;
            FS.Close();
            FS = null;
        }
        private void SP_DataReceived(object sender, SerialDataReceivedEventArgs e)
        {
            int byteCount = ((SerialPort)sender).BytesToRead;

            byte[] buffer = new byte[byteCount]; // a big buffer as we can receive a lot of data.
            ((SerialPort)sender).Read(buffer, 0, byteCount);

            this.dispatcher.BeginInvoke(new MyDelegate(ProcessData), DispatcherPriority.Normal, buffer);
        }
        public delegate void MyDelegate(byte[] inData);
        short prevDataCount = 0;
        byte[] prevData = new byte[2]; // variable to hold any fragments of a broken transmission
        public long ReadingCount = 0;
        /// <summary>
        ///  receive data burst.
        /// </summary>
        /// <param name="inData"></param>
        public void ProcessData(byte[] inData)
        {
            //string newData = String.Empty;
            //newData = BitConverter.ToString(inData);
            //Console.Write(newData);
            // this routine has to sort the data into new lines.
            int byteCount = inData.Length;
            int t = 0;
            ushort val = 0; // variable to hold the recovered data segment.

            if (byteCount == 0)
            { return; // if no data.
            }
            //in case we have a tiny packet.
            if ( byteCount < 3)
            {
                // if not enough data left, then put what we have in the prevDataVariable.
                if (byteCount == 2)
                {
                    prevData[2] = inData[t + 1];
                    prevData[1] = inData[t];
                    prevDataCount = 2;
                }
                else if (byteCount == 1)
                {
                    prevData[1] = inData[t];
                    prevDataCount = 1;
                }
                return;
            }
            // need to align the data loader algorithm.

            // need to check for each scenario for where the delimeter is.
            if (inData[t + 2] == 0x00) //the value of t is the beginning of a data payload. -- perfect arrangement.
            {
                // don't do anything, we are already aligned correctly.
            }
            else if (inData[t + 1] == 0x00)
            {
                if (prevDataCount == 1)
                {
                    byte[] newData = new byte[byteCount + prevDataCount];
                    newData[0] = prevData[0];
                    for (int index = 0; index <= (byteCount - 1); index++)
                    {
                        newData[index + prevDataCount] = inData[index];
                    }
                    inData = newData;
                    byteCount = inData.Length;
                    prevDataCount = 0;
                }
                else
                {
                    Console.ForegroundColor = ConsoleColor.Red;
                    Console.WriteLine("UNRECOVERABLE MALFORMED PACKET!! {0}", prevDataCount);
                    Console.ForegroundColor = ConsoleColor.White;
                    t = t + 2;// skip over the error.
                    //clear out old data.
                    prevDataCount = 0;
                    prevData[0] = 0x00;
                    prevData[1] = 0x00;
                }
            }
            else if (inData[t] == 0x00)
            {
                if (prevDataCount == 2)
                {
                    byte[] newData = new byte[byteCount + prevDataCount];
                    newData[0] = prevData[0];
                    newData[1] = prevData[1];
                    for (int index = 0; index <= (byteCount - 1); index++)
                    {
                        newData[index + prevDataCount] = inData[index];
                    }
                    inData = newData;
                    byteCount = inData.Length;
                    prevDataCount = 0;
                }
                else
                {
                    Console.ForegroundColor = ConsoleColor.Red;
                    Console.WriteLine("UNRECOVERABLE MALFORMED PACKET!! {0}", prevDataCount);
                    Console.ForegroundColor = ConsoleColor.White;
                    t = t + 1; // skip over the malformed packet.
                    //clear out old data.
                    prevDataCount = 0;
                    prevData[0] = 0x00;
                    prevData[1] = 0x00;
                }
            }


            while ((t + 2) <= (byteCount -1))
            {
                int byte1 = t;
                int byte2 = t + 1;
                val = (ushort)(((inData[byte1] & 0x3F) << 8) | inData[byte2]); // get the actual data and remove any error codes.
                t = t + 3;
            }
            if (t != byteCount) // check if there is any partial data left. the normal exit condition is t == byteCount and t pionts to next dataset.
            {
                if (t > byteCount) // there is overshoot. this is an unrecoverable error, whole payload could be bad.
                {
                    Console.WriteLine("TOOMUCH");
                }
                // if not enough data left, then put what we have in the prevDataVariable.
                if ((byteCount - 1) == t + 1)
                {
                    prevData[1] = inData[t + 1];
                    prevData[0] = inData[t];
                    prevDataCount = 2;
                }
                else if (byteCount -1 ==  t)
                {
                    prevData[0] = inData[t];
                    prevDataCount = 1;
                }
            }
            else
            {
                prevDataCount = 0;
            }


            decimal cmH2o = ((val - 1638.0M) / 655.35M) - 10M;
            decimal Pa = cmH2o * 98.0665M;
            Console.WriteLine("Pressure Reading: {0:##.##} Pa", Pa);
            ReadingCount++;
            OutputData.Add(new PressureData(ReadingCount, Pa));

            // write the raw data
            for (int outputByteCount = 0; outputByteCount <= inData.Count() - 1; outputByteCount++)
            {
                if (FS != null) // check the raw file is open before attempting to write to it.
                    FS.WriteByte(inData[outputByteCount]); // write the raw data
            }
        }

        public void ExportNiceData(string FilePath)
        {
            IOrderedEnumerable<PressureData> ExportList = OutputData.OrderBy(x => x.x); // export ordered Data.
            StringBuilder SB = new StringBuilder();
            SB.Append("id, Value(Pa)\r\n");
            foreach ( PressureData data in ExportList)
            {
                SB.AppendFormat("{0}, {1}\r\n", data.x, data.y);
            }
            System.IO.File.WriteAllText(FilePath, SB.ToString());
        }

    }

}

