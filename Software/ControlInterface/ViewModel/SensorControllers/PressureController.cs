﻿using System;
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
        int prevDataCount = 0;
        byte[] prevData = new byte[5]; // variable to hold any fragments of a broken transmission
        long ReadingCount = 0;
        /// <summary>
        ///  receive data burst.
        /// </summary>
        /// <param name="inData"></param>
        public void ProcessData(byte[] inData)
        {
            // write the raw data
            for (int outputByteCount = 0; outputByteCount <= inData.Count() - 1; outputByteCount++)
            {
                if (FS != null) // check the raw file is open before attempting to write to it.
                    FS.WriteByte(inData[outputByteCount]); // write the raw data
            }
            // Dataformat - P1 P2 T1 T2 S1 00
            // this routine has to sort the data into new lines.
            int byteCount = inData.Length;

            if (byteCount == 0)
                return; // if no data.
            //in case we have a tiny packet that it isn't possible to assemble with previous data.
            if ((byteCount + prevDataCount) < 6)
            {
                // if not enough data left, then put what we have in the prevDataVariable.
                for (int c = 0; c < byteCount; c++) // for each byte.
                {
                    prevData[prevDataCount + c] = inData[c];
                    prevDataCount++;
                }
                return;
            }
            // need to align the data loader algorithm, find the delimeter and maybe append the previous data is applicable.
            for (int q = 0; q < 6; q++)
            {
                if (inData[q] == 0x00)
                { // the delimeter is found, q holds the 0 based location of the delimeter!
                    if (q == 5)
                    {
                        // perfect alignment, don't do anything.
                        break;
                    }
                    else
                    {
                        if (q + prevDataCount != 5) // can we assemble the packet ok?
                        { // we don't have the right amount of data to assemble it
                            Console.ForegroundColor = ConsoleColor.Red;
                            Console.WriteLine("UNRECOVERABLE MALFORMED PACKET!! {0}", prevDataCount);
                            Console.ForegroundColor = ConsoleColor.White;
                            prevDataCount = 0; // purge stale data.
                            prevData = new byte[5];
                        }
                        else
                        {
                            // we have the right data to be able to assemble the packet!
                            // insert the new data to the beginning of the array and update the count.
                            byte[] newData = new byte[byteCount + prevDataCount];
                            for (int p = 0; p < prevDataCount; p++)
                            {
                                newData[p] = prevData[p];
                            }
                            for (int index = 0; index < byteCount; index++)
                                newData[index + prevDataCount] = inData[index];
                            inData = newData;
                            byteCount = inData.Length;
                            prevDataCount = 0;
                            prevData = new byte[5];
                        }
                    }
                }
            }


            int t = 0;
            // actually process data.
            while ((t + 5) <= (byteCount - 1))
            {
                int byte1 = t;      // pressure 1
                int byte2 = t + 1;  // pressure 2
                int byte3 = t + 2;  // temperature 1
                int byte4 = t + 3;  // temperature 2
                int byte5 = t + 4;  // sensor Id
                int byte6 = t + 5;
                ushort rawPressure = (ushort)(((inData[byte1] & 0x3F) << 8) | inData[byte2]); // get the actual data and remove any error codes.
                ushort rawTemperature = (ushort)(((inData[byte3]) << 8) | inData[byte4] & 0xE0); // get the temperature data, make sure there isn't any extra crap.
                ushort SensorId = (ushort)(inData[byte5]); // get the sensor Id.
                ushort ErrorCode = (ushort)(inData[byte1] & 0xC0); // get the error code.


                decimal cmH2o = ((rawPressure - 1638.0M) / 655.35M) - 10M;
                decimal Pa = cmH2o * 98.0665M;
                Console.WriteLine("{0}-{1}-{2}-{3}-{4}-{5}", inData[byte1], inData[byte2], inData[byte3], inData[byte4], inData[byte5], inData[byte6]);
                if (inData[byte6] != 0x00)
                {
                    Console.ForegroundColor = ConsoleColor.Red;
                    Console.WriteLine("LOST DATA SYNC!!");
                    Console.ForegroundColor = ConsoleColor.White;
                }
                ReadingCount++;
                OutputData.Add(new PressureData(ReadingCount, Pa, rawTemperature, ErrorCode));
                t = t + 6;
            }

            if (t != byteCount) // check if there is any partial data left. the normal exit condition is t == byteCount and t pionts to next dataset.
            {
                if (t > byteCount) // there is overshoot. this is an unrecoverable error, whole payload could be bad.
                {
                    Console.ForegroundColor = ConsoleColor.Red;
                    Console.WriteLine("TOOMUCH");
                    Console.ForegroundColor = ConsoleColor.White;
                }
                else
                {
                    // if not enough data left, then put what we have in the prevDataVariable.
                    int partialCount = byteCount - t;

                    for (int p = 0; p < partialCount; p++)
                    {
                        prevData[p] = inData[t + p];

                    }
                    prevDataCount = partialCount;
                }
            }
            else
            {
                prevDataCount = 0;
            }
        }

        public void ExportNiceData(string FilePath)
        {
            IOrderedEnumerable<PressureData> ExportList = OutputData.OrderBy(x => x.moment); // export ordered Data.
            StringBuilder SB = new StringBuilder();
            SB.Append("id, Value(Pa), Temperature\r\n");
            foreach (PressureData data in ExportList)
            {
                SB.AppendFormat("{0}, {1}, {2}\r\n", data.moment, data.Pressure, data.Temperature);
            }
            System.IO.File.WriteAllText(FilePath, SB.ToString());
        }

    }

}

