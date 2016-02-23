using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Input;
using System.Windows.Threading;
using ViewModel.SensorControllers;
using Model;

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
            StepperCom = "COM6";
            HotWireCom = "COM14";
        }
        // worker process
       private Dispatcher dispatcher;

        //controllers
     public   PressureController PressureController = null;
      public  StepperController StepperController = null;

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
            StepperController.Connect(StepperCom);
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
        private string _StepperCom;
        public string StepperCom
        {
            get
            {
                return _StepperCom;
            }
            set
            {
                _StepperCom = value;
            }
        }
        private string _HotWireCom;
        public string HotWireCom
        {
            get
            {
                return _HotWireCom;
            }
            set
            {
                _HotWireCom = value;
            }
        }
        public void StepLeft()
        {
            if (StepperController.isBusy == false)
                StepperController.sendCommand(MotorAxis.x, MotorStep.none, MotorSpeed.fast, MotorDirection.left, 6, 0, 0);
        }
        public void StepRight()
        {
            if (StepperController.isBusy == false)
                StepperController.sendCommand(MotorAxis.x, MotorStep.none, MotorSpeed.fast, MotorDirection.right, 6, 0, 0);
        }
        public void StepUp()
        {
            if (StepperController.isBusy == false)
                StepperController.sendCommand(MotorAxis.y, MotorStep.none, MotorSpeed.dynamic, MotorDirection.left, 6, 0, 0);
        }
        public void StepDown()
        {
            if (StepperController.isBusy == false)
                StepperController.sendCommand(MotorAxis.y, MotorStep.none, MotorSpeed.dynamic, MotorDirection.right, 6, 0, 0);
        }

        public void ExportPressure(string FilePath)
        {
            PressureController.ExportNiceData(FilePath);
        }
    }



}
