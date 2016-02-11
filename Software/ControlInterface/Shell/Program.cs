using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Threading;
using System.Runtime.InteropServices;
using System.Timers;
using ViewModel;

namespace Shell
{
    /// <summary>
    ///  this is the actual program, when run() finishes, the program closes.
    /// </summary>
    public static class Program
    {
        public static void run()
        {
            MenuViewModel VM = new MenuViewModel();
            UI.Menu MW = new UI.Menu(ref VM);
            VM.AssignDispatcher(MW.Dispatcher);
            MW.ShowDialog();

        }
    }
}

