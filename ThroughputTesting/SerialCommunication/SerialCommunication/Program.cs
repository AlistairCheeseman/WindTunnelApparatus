using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.IO.Ports;
using System.Timers;

namespace SerialCommunication
{
    class Program
    {
        static public SerialPort sp;
        static void Main(string[] args)
        {
            sp = new SerialPort();
            sp.PortName = "COM14";
            Console.WriteLine("Com port: " + sp.PortName.ToString());
            sp.BaudRate = 200000000;
            Console.WriteLine("Baud rate: " +sp.BaudRate.ToString());
            Console.WriteLine("dataBits: " + sp.DataBits.ToString());
            Console.WriteLine("Stop bit: " + sp.StopBits.ToString());
            Console.WriteLine("Parity bit: " + sp.Parity.ToString());
            Console.WriteLine("Read Timeout: " + sp.ReadTimeout.ToString());
            sp.Handshake = Handshake.RequestToSend;
            sp.DtrEnable = true;    // Data-terminal-ready
            sp.RtsEnable = true;    // Request-to-send
    Console.WriteLine("Press enter to exit");
            Console.WriteLine("\rPackets Recd: ");
            Console.WriteLine("\rTime: " );
            Console.WriteLine("\rMoving Avg: " );
            Console.WriteLine("\rTotal Avg:" );
            sp.ErrorReceived += Sp_ErrorReceived;
            sp.Open();
            sp.DataReceived += sp_DataReceived;
       
        
            packetcount = 0;
            DT = DateTime.Now;
            string test = sp.ReadExisting(); // give it a kickstart
            Timer t = new Timer();
            t.Interval = 1000;
            t.Elapsed += T_Elapsed;
            t.Start();
            Console.ReadLine();

           sp.Close();

        }

        private static double last1 = 0;
            private static double last2 = 0;
            private static double last3= 0;
        private static double max = 0;
        private static double min = 1000000000;
        private static long lastByteCount = 0;
        private static void T_Elapsed(object sender, ElapsedEventArgs e)
        {
            if (lastByteCount == packetcount)
            {
                ((Timer)sender).Stop();
                return;
            }

            last2 = last1;
            last3 = last2;

            TimeSpan TS = DateTime.Now - DT;
             last1 = packetcount / TS.TotalSeconds;
            if (last1 > max)
                max = last1;
            if (last1 < min)
                min = last1;
            double currentAvg = (last1 + last2 + last3) / 3;
            if (TS.Seconds != 0)
            {
                Console.SetCursorPosition(0, Console.CursorTop - 6);
                Console.WriteLine("\rPackets Recd: " + packetcount.ToString());
                Console.WriteLine("\rTime: " + TS.TotalSeconds + " Seconds");
                Console.WriteLine("\rMoving Avg:\t" + String.Format("{0:##,#}", currentAvg) + " Bytes/sec");
                Console.WriteLine("\rTotal Avg:\t" + String.Format("{0:##,#}", packetcount / TS.TotalSeconds) + " Bytes/sec");
                Console.WriteLine("\rMax:\t" + String.Format("{0:##,#}", max) + " Bytes/sec");
                Console.WriteLine("\rMin:\t" + String.Format("{0:##,#}", min) + " Bytes/sec");

            }
            lastByteCount = packetcount;
            GC.Collect();
        }

        private static void Sp_ErrorReceived(object sender, SerialErrorReceivedEventArgs e)
        {
            Console.WriteLine();
            sp.Close();
            Console.WriteLine(e.EventType.ToString());
            Console.ReadLine();
            Console.WriteLine();
        }

        //  public static string partialrecieve;
        public static long packetcount;
        public static DateTime DT;
        private static void sp_DataReceived(object sender, SerialDataReceivedEventArgs e)
        {
            SerialPort sep = (SerialPort)sender;
            //  string indata = sep.ReadExisting();
            // packetcount += indata.Length;
            byte[] buf = new byte[sep.BytesToRead];
            sep.Read(buf, 0, buf.Length);

            packetcount += buf.Length;
            
           

         //   if (indata == "/r" | indata == "/n")
         //   { }
         //   else
         //   {
                //partialrecieve += indata;
             
          //  }
        }
    }
   
}
