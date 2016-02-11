using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Threading;
using System.Runtime.InteropServices;
using System.Timers;

namespace Shell
{
    /// <summary>
    ///  this class is called when the program is started, it hides/shows the console and handles the logging.
    ///  is calls the Program.run() to actually start the program.
    /// </summary>
    class init
    {
        static bool isConsole = false;
        static void Main(string[] args)
        {
            isConsole = consoleHelpers.isConsole();
#if DEBUG
            isConsole = true;
#endif
            try
            {
                if (!isConsole)
                    consoleHelpers.hideWindow();
                System.Threading.Thread thread = new Thread(Program.run);
                thread.SetApartmentState(ApartmentState.STA); //Set the thread to STA
                thread.Start();
                thread.Join(); //Wait for the thread to end
            }
            catch (Exception ex)
            {
                if (!isConsole)
                    consoleHelpers.showWindow();
                Console.WriteLine("FATAL EXCEPTION!");
                Console.WriteLine(ex.Message);
                Console.WriteLine("Press enter to exit");
                Console.ReadLine();
            }
        }
      
    }
    static class consoleHelpers
    {
        const int SW_HIDE = 0;
        const int SW_SHOW = 5;
        public static void hideWindow()
        {
            var handle = unsafeMethods.GetConsoleWindow();
            unsafeMethods.ShowWindow(handle, SW_HIDE);
        }
        public static void showWindow()
        {
            var handle = unsafeMethods.GetConsoleWindow();
            unsafeMethods.ShowWindow(handle, SW_SHOW);
        }
        public static bool isConsole()
        {
            //http://stackoverflow.com/questions/1528152/is-it-possible-to-build-a-console-app-that-does-not-display-a-console-window-whe
            int left = Console.CursorLeft;
            int top = Console.CursorTop;
            bool ProcessWasRunFromExplorer = (left == 0 && top == 0);
            return !ProcessWasRunFromExplorer;
        }
        static class unsafeMethods
        {
            //http://stackoverflow.com/questions/3571627/show-hide-the-console-window-of-a-c-sharp-console-application
            [DllImport("kernel32.dll")]
            public static extern IntPtr GetConsoleWindow();

            [DllImport("user32.dll")]
            public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
        }
    }
}
