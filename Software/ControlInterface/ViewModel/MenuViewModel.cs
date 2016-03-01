using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Input;
using System.Windows.Threading;
using ViewModel.SensorControllers;
using Model;
using ViewModel.Helpers;

namespace ViewModel
{
    /// <summary>
    ///  this class holds all data needed for the user interface. all user clicks/ presses etc get pushed through to here.
    /// </summary>
    public class MenuViewModel : ViewModelBase
    {
        #region Startup routines
        public MenuViewModel()
        {
            //initialise raw values
            PressureCom = "COM9";
            StepperCom = "COM6";
            HotWireCom = "COM14";

            timer.Tick += UIUpdateTimer; // Timer to update UI information
            timer.Interval = new TimeSpan(0, 0, 0, 0,500); //tick every 500ms
            timer.Start();
        }

     
        // worker process
        private Dispatcher dispatcher;

        //controllers
        public PressureController PressureController { get; } = new PressureController();
        public StepperController StepperController { get; } = new StepperController();

        public void AssignDispatcher(Dispatcher dispatcher)
        {
            this.dispatcher = dispatcher;
          //  PressureController.setDispatcher(this.dispatcher);
        }
        #endregion
        #region Connect-DisconnectFunctions
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
        public void ConnectHotWire()
        {

        }
        public void DisconnectHotWire()
        {

        }
        #endregion
        #region COM Port settings.
        private string _PressureCom;
        public string PressureCom
        {
            get
            {
                return _PressureCom;
            }
            set
            {
                this.SetField(ref _PressureCom, value, () => PressureCom);
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
                this.SetField(ref _StepperCom, value, () => StepperCom);
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
                this.SetField(ref _HotWireCom, value, () => HotWireCom);
            }
        }
        #endregion
        #region Step Nudge
        public void StepLeft()
        {
            if (StepperController.isBusy == false && StepperController.isConnected == true)
                StepperController.sendCommand(MotorAxis.x, MotorStep.none, MotorSpeed.fast, MotorDirection.left, 6, 0, 0);
        }
        public void StepRight()
        {
            if (StepperController.isBusy == false && StepperController.isConnected == true)
                StepperController.sendCommand(MotorAxis.x, MotorStep.none, MotorSpeed.fast, MotorDirection.right, 6, 0, 0);
        }
        public void StepUp()
        {
            if (StepperController.isBusy == false && StepperController.isConnected == true)
                StepperController.sendCommand(MotorAxis.y, MotorStep.none, MotorSpeed.fast, MotorDirection.left, 6, 0, 0);
        }
        public void StepDown()
        {
            if (StepperController.isBusy == false && StepperController.isConnected == true)
                StepperController.sendCommand(MotorAxis.y, MotorStep.none, MotorSpeed.fast, MotorDirection.right, 6, 0, 0);
        }
        #endregion
        #region Export
        public void ExportPressure(string FilePath)
        {
            PressureController.ExportNiceData(FilePath);
        }
        public void ExportHotWire(string FilePath)
        {
            
        }
        #endregion
        #region UI Timing
        DispatcherTimer timer = new DispatcherTimer();
        private void UIUpdateTimer(object sender, EventArgs e)
        {
            PressureController.TriggerUIUpdate(); // trigger a request to update the sensor values and graph data.
        }


        #endregion
    }



}
