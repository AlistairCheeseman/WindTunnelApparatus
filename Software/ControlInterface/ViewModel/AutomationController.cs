using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ViewModel
{
   public class AutomationController
    {
        List<Measurement> MeasurementList = new List<Measurement>();
        private class Measurement
        {
            public int id;
            public double Vertical;
            public double Horizontal;
            public double MeasurementTime;
        }
        public void loadStimulusFile(string Filepath, ViewModel.MenuViewModel MVM)
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
                  string[]  rows = line.Split(',');
                int ID = int.Parse(rows[0]);
                double Horizontal = double.Parse(rows[1]);
                double Vertical = double.Parse(rows[2]);
                double MeasurementTime = double.Parse(rows[3]);
                MeasurementList.Add(new Measurement() { id = ID, Horizontal = Horizontal, Vertical = Vertical, MeasurementTime = MeasurementTime });

            }
            MVM.TotalMeasurementCount = MeasurementList.Count();

        }


        public void ExecuteAutomationProcess(ViewModel.MenuViewModel MVM)
        {
            foreach(Measurement mes in MeasurementList.OrderBy(x => x.id))
            {
                // move the stepper motor to the position
                // wait for the flow to settle
                // measure and wait
                // stop measurement
                // repeat

                while (MVM.StepperController.isBusy == true) { System.Threading.Tasks.Task.Delay(1000); } // be sure controller is free before we do anything.
                // move to posn.
                if (MVM.StepperController.gotoHorizontal(mes.Horizontal) == false)
                {
                    // error
                    Console.WriteLine("Horizontal Error");
                }
                while (MVM.StepperController.isBusy == true) { System.Threading.Tasks.Task.Delay(1000); }

                if (MVM.StepperController.gotoVertical(mes.Vertical) == false)
                {
                    // error
                    Console.WriteLine("Vertical Error");
                }
                while (MVM.StepperController.isBusy == true) { System.Threading.Tasks.Task.Delay(1000); }

                System.Threading.Tasks.Task.Delay(new TimeSpan(0, 0, 5)); // wait 5 seconds for flow to settle.

               MVM.PressureController.OutputData.Clear(); // clear out the data .
                System.Threading.Tasks.Task.Delay(new TimeSpan((long)(mes.MeasurementTime * 10.0))); // wait for the appropriate sample time.
                List<Model.PressureData> data = MVM.PressureController.OutputData; // get a copy of the measurements.

               
            }
        }
    }
}
