using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Input;
using System.Windows.Threading;
using ViewModel.SensorControllers;

namespace ViewModel
{
    /// <summary>
    ///  this class holds all data needed for the user interface. all user clicks/ presses etc get pushed through to here.
    /// </summary>
    public class MenuViewModel
    {

        public MenuViewModel()
        {
            //initialise raw values
            PressureCom = "COM9";
        }
        // worker process
       private Dispatcher dispatcher;

        //controllers
        PressureController PressureController = null;
        StepperController StepperController = null;

        public void AssignDispatcher(Dispatcher dispatcher)
        {
            this.dispatcher = dispatcher;
            PressureController = new PressureController(this.dispatcher);
            StepperController =  new StepperController(this.dispatcher);
        }
        // connect up to the pressure sensor.
        public void ConnectPressure()
        {
            PressureController.Connect(PressureCom);

        }
        public void DisconnectPressure()
        {
            PressureController.Disconnect();
        }
        public void ConnectStepper()
        {
            StepperController.Connect("COM1");
        }
        public void DisconnectStepper()
        {
            StepperController.Disconnect();
        }

        private string _PressureCom;
        public string PressureCom
        {
            get
            {
                return _PressureCom;
            }
            set
            {
                _PressureCom = value;
            }
        }
    }



}
