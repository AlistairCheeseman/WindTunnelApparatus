using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.ComponentModel;
using ViewModel.SensorControllers;
using ViewModel.Helpers;
using Model;

namespace ViewModel
{
   public class AutomationController : ViewModelBase
    {
        #region Controllers
        //controllers 
        public PressureController PressureController { get; } = new PressureController();
        public StepperController StepperController { get; } = new StepperController();
        public HotWireController HotWireController { get; } = new HotWireController();
        #endregion
        #region Properties
        private int _CompletedMeasurementCount;
        public int CompletedMeasurementCount
        {
            get
            {
                return _CompletedMeasurementCount;
            }
            set
            {
                this.SetField(ref _CompletedMeasurementCount, value, () => CompletedMeasurementCount);
            }
        }
        private int _TotalMeasurementCount;
        public int TotalMeasurementCount
        {
            get
            {
                return _TotalMeasurementCount;
            }
            set
            {
                this.SetField(ref _TotalMeasurementCount, value, () => TotalMeasurementCount);
            }
        }

        #endregion
        #region public interfaces
        public void BeginWork()
        {
            BGWorker.RunWorkerAsync();
        }
        public void CancelWork()
        {
            BGWorker.CancelAsync();
        }
        public void loadStimulusFile(string Filepath, ViewModel.MenuViewModel MVM)
        {
            if (BGWorker.IsBusy == false)
            {
                MeasurementList = new List<Measurement>();
                bool headerLine = false;
                foreach (string line in System.IO.File.ReadAllLines(Filepath))
                {
                    if (headerLine == false)
                    {
                        headerLine = true;
                        continue;
                    }
                    string[] rows = line.Split(',');
                    int ID = int.Parse(rows[0]);
                    double Horizontal = double.Parse(rows[1]);
                    double Vertical = double.Parse(rows[2]);
                    double MeasurementTime = double.Parse(rows[3]);
                    double _SettleTime = double.Parse(rows[4]);
                    MeasurementList.Add(new Measurement() { id = ID, Horizontal = Horizontal, Vertical = Vertical, MeasurementTime = MeasurementTime, SettleTime = _SettleTime });

                }
                TotalMeasurementCount = MeasurementList.Count();
            }
        }
        public void ExportData(string ExportFolderPath)
        {
            StringBuilder PressureExport = new StringBuilder();
            StringBuilder HotwireExport = new StringBuilder();

            PressureExport.Append("LoactionId, VerticalPosn (mm), HortizontalPosn. (mm), Measurementid, Time, Value1(Pa), Temperature1(C), Value2(Pa), Temperature2(C), Value3(Pa), Temperature3(C), Value4(Pa), Temperature4(C), Value5(Pa), Temperature5(C), Value6(Pa), Temperature6(C), Value7(Pa), Temperature7(C), Value8(Pa), Temperature8(C), Value9(Pa), Temperature9(C), Value10(Pa), Temperature10(C)\r\n");
            HotwireExport.Append("LocationId, VerticalPosn (mm), HorizontalPosn (mm), Measurementid, Time, HotWire1\r\n");
            foreach (AutomationMeasurement AM in MeasurementData.OrderBy(x => x.id)) // export the measurements in the order they were taken.
            {
                long LocationId = AM.id; // id of the input location measurement.
                double verticalmm = AM.PosnVert; // mm of the vertical from origin
                double horizontalmm = AM.PosnHoriz; // mm of the horizontal from origin.

                // write all the pressure readings for this location.
                List<PressureExportData> Exportdata = PressureController.getExportData(AM.PressureReadings);
                foreach (PressureExportData ED in Exportdata)
                {
                    PressureExport.AppendFormat("{0}\r\n",
                    LocationId.ToString("##.##") + verticalmm.ToString("##.##") + horizontalmm.ToString("##.##") +
                    ED.id.ToString() +  ED.moment.ToString("H:mm:ss.fffff") + 
                    ED.Pressure1 +  ED.Temperature1 +
                    ED.Pressure2 + ED.Temperature2 +
                    ED.Pressure3 + ED.Temperature3 +
                    ED.Pressure4 + ED.Temperature4 +
                    ED.Pressure5 + ED.Temperature5 +
                    ED.Pressure6 + ED.Temperature6 +
                    ED.Pressure7 + ED.Temperature7 +
                    ED.Pressure8 + ED.Temperature8 +
                    ED.Pressure9 + ED.Temperature9 +
                    ED.Pressure10 + ED.Temperature10
                    );
                }
                IOrderedEnumerable<HotWireData> HotWireDataList = AM.HotWireReadings.OrderBy(x => x.id); // export ordered Data.
                //write all the hotwire data for this location.
                foreach (HotWireData data in HotWireDataList)
                {
                    HotwireExport.AppendFormat("{0}, {1:H:mm:ss.fffff}, {2}\r\n",
                    data.id, data.moment, data.measurement);
                }
            }
            System.IO.File.WriteAllText(ExportFolderPath + "HotWireData.csv", HotwireExport.ToString());
            System.IO.File.WriteAllText(ExportFolderPath + "PressureData.csv", PressureExport.ToString());


        }
        #endregion
        List<Measurement> MeasurementList = new List<Measurement>(); //list of measurements to be made
        List<AutomationMeasurement> MeasurementData = new List<AutomationMeasurement>(); // container for the measurements themselves
        BackgroundWorker BGWorker = new BackgroundWorker();
        public AutomationController()
        {
            BGWorker.WorkerSupportsCancellation = true;
            BGWorker.DoWork += BGWorker_DoWork; // the actual work to be done
            BGWorker.RunWorkerCompleted += BGWorker_RunWorkerCompleted; // what to call when the worker has finished.
        }

        #region events
        public delegate void AutomationCompleted();
        public event AutomationCompleted AutomationCompletedEvent;
        #endregion

        #region Internal automation worker Methods

        private void BGWorker_RunWorkerCompleted(object sender, RunWorkerCompletedEventArgs e)
        {
            // all measurements have been completed.
            // prompt the user to export the data, this is a user function so notify the VM to do the prompt.
            if (AutomationCompletedEvent != null)
                AutomationCompletedEvent();
            else
                Console.WriteLine("The Automation event is not being listened to. So no notification has occurred for the automation completed.");
        }
        private void BGWorker_DoWork(object sender, DoWorkEventArgs e)
        {
            foreach (Measurement mes in MeasurementList.OrderBy(x => x.id))
            {
                // move the stepper motor to the position
                // wait for the flow to settle
                // measure and wait
                // stop measurement
                // repeat
                if (BGWorker.CancellationPending == true)
                {
                    e.Cancel = true;
                    return; // quit out of the worker process.
                }
                if (StepperController.isConnected == true)
                {
                    while (StepperController.isBusy == true)
                    {
                        System.Threading.Thread.Sleep(1000);
                    } // be sure controller is free before we do anything.


                    // move to X posn.
                    if (StepperController.gotoHorizontal((long)(mes.Horizontal * 1000.0)) == false)
                    {
                        // error
                        Console.WriteLine("Horizontal Error");
                    }
                    while (StepperController.isBusy == true)
                    {
                        System.Threading.Thread.Sleep(1000);
                    }

                    //move to Y posn
                    if (StepperController.gotoVertical((long)(mes.Vertical * 1000.0)) == false)
                    {
                        // error
                        Console.WriteLine("Vertical Error");
                    }
                    while (StepperController.isBusy == true)
                    {
                        System.Threading.Thread.Sleep(1000);
                    }
                }

                int seconds = (int)mes.SettleTime;
                int milliseconds = (int)((mes.SettleTime % 1) * 1000.0);

                System.Threading.Thread.Sleep(new TimeSpan(0, 0,0,seconds, milliseconds)); // wait for flow to settle.
                PressureController.OutputData.Clear(); // clear out the data .
                HotWireController.OutputData.Clear();
                System.Threading.Thread.Sleep(new TimeSpan((long)(mes.MeasurementTime * 10.0))); // wait for the appropriate sample time.
                MeasurementData.Add(new AutomationMeasurement(mes.id, mes.Horizontal, mes.Vertical, PressureController.OutputData, HotWireController.OutputData)); // get a copy of the measurements.
                CompletedMeasurementCount++;
            }
        }
        #endregion
    }
}
