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
        private string _AtmosPres = "1007.7";
        public string AtmosPres
        {
            get
            {
                return _AtmosPres;
            }
            set
            {
                this.SetField(ref _AtmosPres, value, () => AtmosPres);
            }

        }
        private string _AtmosTemp = "22";
        public string AtmosTemp
        {
            get
            {
                return _AtmosTemp;
            }
            set
            {
                this.SetField(ref _AtmosTemp, value, () => AtmosTemp);
            }

        }
        
        #endregion
        #region public interfaces
      
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
        public long ExportData(string ExportFolderPath)
        {
            StringBuilder PressureExport = new StringBuilder();
            StringBuilder HotwireExport = new StringBuilder();

            PressureExport.Append("VerticalPosn (mm), HortizontalPosn. (mm), Atmospheric Pressure (hPa), Ambient Temp (C), Value1(Pa) Avg, Value2(Pa), Value3(Pa), Value4(Pa), Value5(Pa), Value6(Pa), Value7(Pa), Value8(Pa), Value9(Pa), Value10(Pa)\r\n");
            HotwireExport.Append("LocationId, VerticalPosn (mm), HorizontalPosn (mm), Measurementid, Time, HotWire1\r\n");
            int Locationcount = MeasurementData.Count();
            for (int currentPosn = 0; currentPosn < Locationcount; currentPosn++) // export the measurements in the order they were taken.
            {

                long LocationId = MeasurementData[currentPosn].id; // id of the input location measurement.
                double verticalmm = MeasurementData[currentPosn].PosnVert; // mm of the vertical from origin
                double horizontalmm = MeasurementData[currentPosn].PosnHoriz; // mm of the horizontal from origin.

               PressureExport.AppendFormat("{0}\r\n",

                  verticalmm.ToString() + "," + horizontalmm.ToString() + "," +
                  this.AtmosPres + "," + this.AtmosTemp + "," +
                  MeasurementData[currentPosn].Pressure1Avg + "," +
                  MeasurementData[currentPosn].Pressure2Avg + "," +
                  MeasurementData[currentPosn].Pressure3Avg + "," +
                  MeasurementData[currentPosn].Pressure4Avg + "," +
                  MeasurementData[currentPosn].Pressure5Avg + "," +
                  MeasurementData[currentPosn].Pressure6Avg + "," +
                  MeasurementData[currentPosn].Pressure7Avg + "," +
                  MeasurementData[currentPosn].Pressure8Avg + "," +
                  MeasurementData[currentPosn].Pressure9Avg + "," +
                  MeasurementData[currentPosn].Pressure10Avg
                  );
             /*   IOrderedEnumerable<HotWireData> HotWireDataList = AM.HotWireReadings.OrderBy(x => x.id); // export ordered Data.
                //write all the hotwire data for this location.
                foreach (HotWireData data in HotWireDataList)
                {
                    HotwireExport.AppendFormat("{0}, {1:H:mm:ss.fffff}, {2}\r\n",
                    data.id, data.moment, data.measurement);
                }*/
            }
            long HotWireLineCount = HotwireExport.ToString().Split('\n').Count() - 1;
            if (HotWireLineCount > 1)
            {
                System.IO.File.WriteAllText(ExportFolderPath + "HotWireData.csv", HotwireExport.ToString());
            }
            long PressureLineCount = PressureExport.ToString().Split('\n').Count() - 1;
            if (PressureLineCount > 1)
            {
                System.IO.File.WriteAllText(ExportFolderPath + "PressureData.csv", PressureExport.ToString());
            }
            return HotWireLineCount + PressureLineCount; // return the number of records exported.

        }
        #endregion
        List<Measurement> MeasurementList = new List<Measurement>(); //list of measurements to be made
        List<AutomationMeasurement> MeasurementData = new List<AutomationMeasurement>(); // container for the measurements themselves
        public AutomationController()
        {
           }

        #region events
        public delegate void AutomationCompleted();
        public event AutomationCompleted AutomationCompletedEvent;
        #endregion

        #region Internal automation worker Methods   

    // private void BGWorker_DoWork(object sender, DoWorkEventArgs e)
    public async Task Automate()
        {
            long PressureMeasurementCount = 0;
            foreach (Measurement mes in MeasurementList.OrderBy(x => x.id))
            {
                continue;
                // move the stepper motor to the position
                // wait for the flow to settle
                // measure and wait
                // stop measurement
                // repeat
                /*  if (BGWorker.CancellationPending == true)
                  {
                      e.Cancel = true;
                      return; // quit out of the worker process.
                  }*/
                double Pressure1Avg = 0;
                double Pressure2Avg = 0;
                double Pressure3Avg = 0;
                double Pressure4Avg = 0;
                double Pressure5Avg = 0;
                double Pressure6Avg = 0;
                double Pressure7Avg = 0;
                double Pressure8Avg = 0;
                double Pressure9Avg = 0;
                double Pressure10Avg = 0;


                bool goodReading = false;
                while (goodReading == false)
                {
                    if (StepperController.isConnected == true)
                    {
                        while (StepperController.isBusy == true)
                        {
                            // System.Threading.Thread.Sleep(1000);
                            await Task.Delay(1000);
                        } // be sure controller is free before we do anything.


                        // move to X posn.
                        if (StepperController.gotoHorizontal((long)(mes.Horizontal * 1000.0)) == false)
                        {
                            // error
                            Console.WriteLine("Horizontal Error");
                        }
                        while (StepperController.isBusy == true)
                        {
                            //System.Threading.Thread.Sleep(1000);
                            await Task.Delay(1000);
                        }

                        //move to Y posn
                        if (StepperController.gotoVertical((long)(mes.Vertical * 1000.0)) == false)
                        {
                            // error
                            Console.WriteLine("Vertical Error");
                        }
                        while (StepperController.isBusy == true)
                        {
                            await Task.Delay(1000);
                            //System.Threading.Thread.Sleep(1000);
                        }
                    }

                    int seconds = (int)mes.SettleTime;
                    int milliseconds = (int)((mes.SettleTime % 1) * 1000.0);

                    // System.Threading.Thread.Sleep(new TimeSpan(0, 0,0,seconds, milliseconds)); // wait for flow to settle.
                    await Task.Delay(new TimeSpan(0, 0, 0, seconds, milliseconds));
                    PressureController.OutputData = new List<PressureData>(); // clear out the data fully.
                    HotWireController.OutputData = new List<HotWireData>(); // clear out the data fully
                    PressureController.RecordData = true;
                    //  System.Threading.Thread.Sleep(new TimeSpan((long)(mes.MeasurementTime * 10.0))); // wait for the appropriate sample time.
                    await Task.Delay(new TimeSpan(0, 0, 0, seconds, milliseconds + 5)); // add a little to allow for the time for the property to update
                    PressureController.RecordData = false;

                    List<PressureData> Pressure = PressureController.OutputData.ToList();

                    List<PressureExportData> Exportdata = PressureController.getExportData(Pressure, ref PressureMeasurementCount);
                    Console.WriteLine(Exportdata.Count() + " Readings Taken");
                    Pressure1Avg = Exportdata.Average(x => x.Pressure1);
                    Pressure2Avg = Exportdata.Average(x => x.Pressure2);
                    Pressure3Avg = Exportdata.Average(x => x.Pressure3);
                    Pressure4Avg = Exportdata.Average(x => x.Pressure4);
                    Pressure5Avg = Exportdata.Average(x => x.Pressure5);
                    Pressure6Avg = Exportdata.Average(x => x.Pressure6);
                    Pressure7Avg = Exportdata.Average(x => x.Pressure7);
                    Pressure8Avg = Exportdata.Average(x => x.Pressure8);
                    Pressure9Avg = Exportdata.Average(x => x.Pressure1);
                    Pressure10Avg = Exportdata.Average(x => x.Pressure1);
                    if (Pressure4Avg == 0)
                    {
                        Console.WriteLine("RESET FPGA - BAD READING!");
                        Pressure1Avg = 0;
                        Pressure2Avg = 0;
                        Pressure3Avg = 0;
                        Pressure4Avg = 0;
                        Pressure5Avg = 0;
                        Pressure6Avg = 0;
                        Pressure7Avg = 0;
                        Pressure8Avg = 0;
                        Pressure9Avg = 0;
                        Pressure10Avg = 0;
                    }
                    else
                    {
                        goodReading = true;
                        break;
                    }


                } // end while  - got reading.


                MeasurementData.Add(new AutomationMeasurement(mes.id, mes.Horizontal, mes.Vertical,Pressure1Avg, Pressure2Avg, Pressure3Avg,Pressure4Avg,Pressure5Avg, Pressure6Avg, Pressure7Avg,Pressure8Avg,Pressure9Avg,Pressure10Avg, HotWireController.OutputData.ToList())); // get a copy of the measurements.
                CompletedMeasurementCount++;
            } // move to next measurement
            Console.WriteLine("Done!");
            if (AutomationCompletedEvent != null)
                AutomationCompletedEvent();
        }
        #endregion
    }
}
