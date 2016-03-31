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
            this.AutomationController.AutomationCompletedEvent += AutomationController_AutomationCompletedEvent;
        }

        private void AutomationController_AutomationCompletedEvent()
        {
            // the automation controller has completed the measurement portion, it now just needs to display a prompt to ask the user where to save the results.
            // pass the event up to the UI!
            if (AutomationCompletedEvent != null)
                AutomationCompletedEvent();
            else
                Console.WriteLine("UI is not listening to automation completed events.");
        }

        public AutomationController AutomationController { get; } = new AutomationController();
        #endregion
        #region Connect-DisconnectFunctions
        public void ConnectPressure()
        {
            AutomationController.PressureController.Connect(PressureCom);
        }
        public void DisconnectPressure()
        {
            AutomationController.PressureController.Disconnect();
        }
        public void ConnectStepper()
        {
            AutomationController.StepperController.Connect(StepperCom);
        }
        public void DisconnectStepper()
        {
            AutomationController.StepperController.Disconnect();
        }
        public void ConnectHotWire()
        {
            AutomationController.HotWireController.Connect(HotWireCom);
        }
        public void DisconnectHotWire()
        {
            AutomationController.HotWireController.Disconnect();
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
            if (AutomationController.StepperController.isBusy == false && AutomationController.StepperController.isConnected == true)
                AutomationController.StepperController.sendCommand(MotorAxis.x, MotorStep.none, MotorSpeed.fast, MotorDirection.left, 6, 0, 0);
        }
        public void StepRight()
        {
            if (AutomationController.StepperController.isBusy == false && AutomationController.StepperController.isConnected == true)
                AutomationController.StepperController.sendCommand(MotorAxis.x, MotorStep.none, MotorSpeed.fast, MotorDirection.right, 6, 0, 0);
        }
        public void StepUp()
        {
            if (AutomationController.StepperController.isBusy == false && AutomationController.StepperController.isConnected == true)
                AutomationController.StepperController.sendCommand(MotorAxis.y, MotorStep.none, MotorSpeed.fast, MotorDirection.left, 6, 0, 0);
        }
        public void StepDown()
        {
            if (AutomationController.StepperController.isBusy == false && AutomationController.StepperController.isConnected == true)
                AutomationController.StepperController.sendCommand(MotorAxis.y, MotorStep.none, MotorSpeed.fast, MotorDirection.right, 6, 0, 0);
        }
        #endregion
        #region Export
        public void ExportPressure(string FilePath)
        {
            AutomationController.PressureController.ExportNiceData(FilePath);
        }
        public void ExportHotWire(string FilePath)
        {
            AutomationController.HotWireController.Export(FilePath);
        }
        public void ExportAll(string FilePath)
        {
            AutomationController.ExportData(FilePath);
        }
        #endregion
        #region UI Timing
        DispatcherTimer timer = new DispatcherTimer();
        private void UIUpdateTimer(object sender, EventArgs e)
        {
            AutomationController.PressureController.TriggerUIUpdate(); // trigger a request to update the sensor values and graph data.
            AutomationController.HotWireController.TriggerUIUpdate();
        }


        #endregion

        public void LoadStimulus(string FilePath) // load the stimulus file and process it ready for the exectuion.
        {
            AutomationController.loadStimulusFile(FilePath, this);
        }
        public void ExecuteMeasurementCycle()
        {
            AutomationController.BeginWork();
        }

        #region events
        public delegate void AutomationCompleted();
        public event AutomationCompleted AutomationCompletedEvent;
        #endregion
    }



}
