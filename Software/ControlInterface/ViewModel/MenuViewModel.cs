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
            //initialise default values
            PressureCom = "COM8"; 
            StepperCom = "COM14";
            HotWireCom = "COM14";

            timer.Tick += UIUpdateTimer; // Timer to update UI information
            timer.Interval = new TimeSpan(0, 0, 0, 0,500); //tick every 500ms - causing the UI to update every 500 ms
            timer.Start(); // begin the timer
            this.AutomationController.AutomationCompletedEvent += AutomationController_AutomationCompletedEvent; // tie up the completed event.
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

        public AutomationController AutomationController { get; } = new AutomationController(); // create an instance of the automation controller.
        #endregion
        #region Connect-DisconnectFunctions
        //simple connect or disconnect functions. connect provides the necessary com port to connect to.
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
        // com port indentifies which sensor is connected to what com port.
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
        //step in a relevant direction but check if the controller is connected and if it is busy.
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
        //simply trigger an export.
        public void ExportPressure(string FilePath)
        {
            AutomationController.PressureController.ExportNiceData(FilePath);
        }
        public void ExportHotWire(string FilePath)
        {
            AutomationController.HotWireController.Export(FilePath);
        }
        public long ExportAll(string FilePath)
        {
           return AutomationController.ExportData(FilePath);
        }
        #endregion
        #region UI Timing
        // timer to create the update event
        DispatcherTimer timer = new DispatcherTimer();
        private void UIUpdateTimer(object sender, EventArgs e)
        {
            // request an update from the pressure controller and the hot wire controller
            AutomationController.PressureController.TriggerUIUpdate(); // trigger a request to update the sensor values and graph data.
            AutomationController.HotWireController.TriggerUIUpdate();
        }


        #endregion

        public void LoadStimulus(string FilePath) // load the stimulus file and process it ready for the exectuion.
        {// load the stimulus file.
            AutomationController.loadStimulusFile(FilePath, this);
        }
        public async Task ExecuteMeasurementCycle()
        {// execute the automate function!
            await AutomationController.Automate();
        }

        #region events
        //event to be triggered when the automation has completed.
        public delegate void AutomationCompleted();
        public event AutomationCompleted AutomationCompletedEvent;
        #endregion
    }



}
