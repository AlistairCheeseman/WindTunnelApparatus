using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Threading;
using System.Runtime.InteropServices;
using System.Timers;

namespace Test.Shell
{

    class Program
    {
        static DateTime startTime;
        static uint bytesRec;
        static System.Timers.Timer t;

        static void Main(string[] args)
        {
            t = new System.Timers.Timer();
            t.Interval = 1000;
            t.Elapsed += T_Elapsed;


            try
            {
                System.Net.IPAddress IP = System.Net.IPAddress.Parse("192.168.3.22");
                System.Net.Sockets.TcpListener listener = new System.Net.Sockets.TcpListener(IP, 1955);
                Console.WriteLine("\rPackets Recd: ");
                Console.WriteLine("\rTime: " + " Seconds");
                Console.WriteLine("\rMoving Avg:\t  Bytes/sec");
                Console.WriteLine("\rTotal Avg:\t  Bytes/sec");
                Console.WriteLine("\rMax:\t Bytes/sec");
                Console.WriteLine("\rMin:\t Bytes/sec");
                listener.Start();
                while (true)
                {
                    System.Net.Sockets.Socket client = listener.AcceptSocket();
                    Console.WriteLine("Connection accepted.");
                    startTime = DateTime.Now;
                    bytesRec = 0;
                    t.Start();
                    var childSocketThread = new Thread(() =>
                    {
                        while (client.Connected == true)
                        {
                            byte[] data = new byte[1000];
                            int size = client.Receive(data);
                            bytesRec += uint.Parse(size.ToString());
                            /*                            Console.WriteLine("Recieved data: ");
                                                        for (int i = 0; i < size; i++)
                                                            Console.Write(Convert.ToChar(data[i]));
                                                      Console.WriteLine(); */

                        }
                        client.Close();
                    });
                    childSocketThread.Start();
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
                ((System.Timers.Timer)sender).Stop();
                return;
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

