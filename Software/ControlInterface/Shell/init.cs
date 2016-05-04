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
            isConsole = consoleHelpers.isConsole(); // check if the program was called from the console.
#if DEBUG
            isConsole = true; // if debug, force the program to keep the console displayed.
#endif
            try
            {
                if (!isConsole) // if we are not a console session, close the console that the program creates
                    consoleHelpers.hideWindow();
                System.Threading.Thread thread = new Thread(Program.run); // create a program thread to run the main program
                thread.SetApartmentState(ApartmentState.STA); //Set the thread to STA
                thread.Start(); // start the thread
                thread.Join(); //Wait for the thread to end
            }
            catch (Exception ex)
            { // some basic error handling
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
        // a few console helper functions to make doing things easier.
        const int SW_HIDE = 0;
        const int SW_SHOW = 5;
        public static void hideWindow() // hide the console window
        {
            var handle = unsafeMethods.GetConsoleWindow();
            unsafeMethods.ShowWindow(handle, SW_HIDE);
        }
        public static void showWindow() // show the console window
        {
            var handle = unsafeMethods.GetConsoleWindow();
            unsafeMethods.ShowWindow(handle, SW_SHOW);
        }
        public static bool isConsole() //detect if we have been called from a console session
        {
            //http://stackoverflow.com/questions/1528152/is-it-possible-to-build-a-console-app-that-does-not-display-a-console-window-whe
            int left = Console.CursorLeft;
            int top = Console.CursorTop;
            bool ProcessWasRunFromExplorer = (left == 0 && top == 0);
            return !ProcessWasRunFromExplorer;
        }
        static class unsafeMethods
        { // a class for any DLL calls.
            //http://stackoverflow.com/questions/3571627/show-hide-the-console-window-of-a-c-sharp-console-application
            [DllImport("kernel32.dll")]
            public static extern IntPtr GetConsoleWindow();

            [DllImport("user32.dll")]
            public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
        }
    }
}
