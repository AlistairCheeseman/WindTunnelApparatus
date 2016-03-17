using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.ComponentModel;
using ViewModel.SensorControllers;
using ViewModel.Helpers;

namespace ViewModel
{
   public class AutomationController : ViewModelBase
    {
        #region Controllers
        //controllers
        public PressureController PressureController { get; } = new PressureController();
        public StepperController StepperController { get; } = new StepperController();




        #endregion




        List<Measurement> MeasurementList = new List<Measurement>();
        BackgroundWorker BGWorker = new BackgroundWorker();
        SensorControllers.PressureController PC;
        SensorControllers.StepperController SC;
        public AutomationController()
        {
            BGWorker.WorkerSupportsCancellation = true;
            BGWorker.DoWork += BGWorker_DoWork;
        }
        public void AssignControllers(ref SensorControllers.PressureController PC, ref SensorControllers.StepperController SC)
        {
            this.SC = SC;
            this.PC = PC;
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


                System.Threading.Thread.Sleep(new TimeSpan(0, 0, 5)); // wait 5 seconds for flow to settle.
                PressureController.OutputData.Clear(); // clear out the data .
                System.Threading.Thread.Sleep(new TimeSpan((long)(mes.MeasurementTime * 10.0))); // wait for the appropriate sample time.
                List<Model.PressureData> data = PressureController.OutputData; // get a copy of the measurements.
                CompletedMeasurementCount++;
            }
        }

        private class Measurement
        {
            public int id;
            public double Vertical;
            public double Horizontal;
            public double MeasurementTime;
        }
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
                    MeasurementList.Add(new Measurement() { id = ID, Horizontal = Horizontal, Vertical = Vertical, MeasurementTime = MeasurementTime });

                }
                TotalMeasurementCount = MeasurementList.Count();
            }
        }
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
    }
}
