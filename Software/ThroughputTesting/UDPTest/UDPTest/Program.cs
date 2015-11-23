using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Threading;
using System.Runtime.InteropServices;
using System.Timers;

namespace UDPTest
{

    class Program
    {
        static DateTime startTime;
        static long bytesRec;
        static System.Timers.Timer t;

        static void Main(string[] args)
        {
            t = new System.Timers.Timer();
            t.Interval = 1000;
            t.Elapsed += T_Elapsed;


            try
            {
                System.Net.IPEndPoint groupEP = new System.Net.IPEndPoint(System.Net.IPAddress.Any,5001);
                System.Net.Sockets.UdpClient listener = new System.Net.Sockets.UdpClient(groupEP);
                Console.WriteLine("\rPackets Recd: ");
                Console.WriteLine("\rTime: " + " Seconds");
                Console.WriteLine("\rMoving Avg:\t  Bytes/sec");
                Console.WriteLine("\rTotal Avg:\t  Bytes/sec");
                Console.WriteLine("\rMax:\t Bytes/sec");
                Console.WriteLine("\rMin:\t Bytes/sec");
                while (listener.Receive(ref groupEP).Length == 0)
                {}
                startTime = DateTime.Now;
                bytesRec = 0;
                t.Start();
                byte[] data;
                while (true)
                {
                    data = listener.Receive(ref groupEP);
                   
                    bytesRec += data.Length;
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine("FATAL EXCEPTION!");
                Console.WriteLine(ex.Message);
                Console.WriteLine("Press enter to exit");
                Console.ReadLine();
            }
        }


        private static double last1 = 0;
        private static double last2 = 0;
        private static double last3 = 0;
        private static double max = 0;
        private static double min = 1000000000;
        private static long lastByteCount = 0;
        static void T_Elapsed(object sender, ElapsedEventArgs e)
        {
            if (lastByteCount == bytesRec)
            {
              //  ((System.Timers.Timer)sender).Stop();
              //  return;
            }

            last2 = last1;
            last3 = last2;

            TimeSpan TS = DateTime.Now - startTime;
            last1 = bytesRec / TS.TotalSeconds;
            if (last1 > max)
                max = last1;
            if (last1 < min)
                min = last1;
            double currentAvg = (last1 + last2 + last3) / 3;
            if (TS.Seconds != 0)
            {
                Console.SetCursorPosition(0, Console.CursorTop - 6);
                Console.WriteLine("\rPackets Recd: " + bytesRec.ToString());
                Console.WriteLine("\rTime: " + TS.TotalSeconds + " Seconds");
                Console.WriteLine("\rMoving Avg:\t" + String.Format("{0:##,#}", currentAvg) + " Bytes/sec");
                Console.WriteLine("\rTotal Avg:\t" + String.Format("{0:##,#}", bytesRec / TS.TotalSeconds) + " Bytes/sec");
                Console.WriteLine("\rMax:\t" + String.Format("{0:##,#}", max) + " Bytes/sec");
                Console.WriteLine("\rMin:\t" + String.Format("{0:##,#}", min) + " Bytes/sec");

            }
            lastByteCount = bytesRec;
        }

    }
}

