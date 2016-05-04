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
        //controllers  for sensors
        public PressureController PressureController { get; } = new PressureController();
        public StepperController StepperController { get; } = new StepperController();
        public HotWireController HotWireController { get; } = new HotWireController();
        #endregion
        #region Properties

        // basically a progress counter.
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
        // the total number of measurements to be made.
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
        // the current atmospheric pressure, default to 1007.7 as that is the nominal pressure for this scenario, to save time.
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
        // the temperature, normally 22 degrees to save time.
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
        // is the automation paused?
        public bool isPaused
        {
            get; set;
        } = false;
    
        #endregion
        #region public interfaces
      
        public void loadStimulusFile(string Filepath, ViewModel.MenuViewModel MVM)
        {
            //load the stimulus file and covert the locations into a set of measurements to be made.
                bool headerLine = false; // has the headerline been read (1st line in the input file)?
                foreach (string line in System.IO.File.ReadAllLines(Filepath)) // for each line in the input file.
                {
                    if (headerLine == false) // has the header line been read
                    {
                        headerLine = true; // skip it and set the flag.
                        continue;
                    }
                    string[] rows = line.Split(','); // split the row into an array
                    int ID = int.Parse(rows[0]); // get the reading id
                    double Horizontal = double.Parse(rows[1]); // get the horizontal location
                    double Vertical = double.Parse(rows[2]); // get the vertical location
                    double MeasurementTime = double.Parse(rows[3]); // get the time to measure
                    double _SettleTime = double.Parse(rows[4]); // get the time to wait before measuring
                    MeasurementList.Add(new Measurement() { id = ID, Horizontal = Horizontal, Vertical = Vertical, MeasurementTime = MeasurementTime, SettleTime = _SettleTime }); // add the parsed data to the measurement list

                }
                TotalMeasurementCount = MeasurementList.Count(); // udate the measurement count.
        }
        public long ExportData(string ExportFolderPath)
        {
            // export the collected data.
            //container to build the data before writing
            StringBuilder PressureExport = new StringBuilder(); 
            StringBuilder HotwireExport = new StringBuilder();
            // write the file headers.
            PressureExport.Append("VerticalPosn (mm), HortizontalPosn. (mm), Atmospheric Pressure (hPa), Ambient Temp (C), Value1(Pa) Avg, Value2(Pa), Value3(Pa), Value4(Pa), Value5(Pa), Value6(Pa), Value7(Pa), Value8(Pa), Value9(Pa), Value10(Pa)\r\n");
            HotwireExport.Append("LocationId, VerticalPosn (mm), HorizontalPosn (mm), Measurementid, Time, HotWire1\r\n");
            // the number of locations to be written
            int Locationcount = MeasurementData.Count();
            for (int currentPosn = 0; currentPosn < Locationcount; currentPosn++) // export the measurements in the order they were taken.
            {

                long LocationId = MeasurementData[currentPosn].id; // id of the input location measurement.
                double verticalmm = MeasurementData[currentPosn].PosnVert; // mm of the vertical from origin
                double horizontalmm = MeasurementData[currentPosn].PosnHoriz; // mm of the horizontal from origin.

                //actually write the data
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

                //disable the hot wire export for the time being to speed export routine
             /*   IOrderedEnumerable<HotWireData> HotWireDataList = AM.HotWireReadings.OrderBy(x => x.id); // export ordered Data.
                //write all the hotwire data for this location.
                foreach (HotWireData data in HotWireDataList)
                {
                    HotwireExport.AppendFormat("{0}, {1:H:mm:ss.fffff}, {2}\r\n",
                    data.id, data.moment, data.measurement);
                }*/
            }
            long HotWireLineCount = HotwireExport.ToString().Split('\n').Count() - 1; // get how many mesurements
            if (HotWireLineCount > 1)// if there is data to write
            {
                System.IO.File.WriteAllText(ExportFolderPath + "HotWireData.csv", HotwireExport.ToString());  // write the data
            }
            long PressureLineCount = PressureExport.ToString().Split('\n').Count() - 1;// get how many mesurements
            if (PressureLineCount > 1)// if there is data to write
            {
                System.IO.File.WriteAllText(ExportFolderPath + "PressureData.csv", PressureExport.ToString()); // write the data.
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
        // this delegate and event are triggered when the automation has completed.
        public delegate void AutomationCompleted();
        public event AutomationCompleted AutomationCompletedEvent;
        #endregion

        #region Internal automation worker Methods   
        //is the automation to be aborted?
        public bool abort
        {
            get; set;
        } = false;
    // private void BGWorker_DoWork(object sender, DoWorkEventArgs e)
    // the actual routine that controls the automations. 
    public async Task Automate()
        {
            MeasurementData = new List<AutomationMeasurement>(); // container for the data to be stored in.
            long PressureMeasurementCount = 0; // current measurement count
            foreach (Measurement mes in MeasurementList.OrderBy(x => x.id)) // order the measurements by the id. then for each ORDERED reading
            {
                if (abort == true)
                {
                    continue; // skip the reading all the way to the end.
                }

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
                  //initialise each sensor average
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
                while (goodReading == false) // a quick while loop to make sure the reading is good and to repeat if not.
                {
                    if (StepperController.isConnected == true) // check the stepper motor is connected. If it it not, the automation may not need a movement component, so skip the move. 
                    {
                        while (StepperController.isBusy == true) // check the motor is available and wait if not.
                        {
                            // System.Threading.Thread.Sleep(1000);
                            await Task.Delay(1000);
                        } // be sure controller is free before we do anything.

                        if (StepperController.xPositionmm != mes.Horizontal) // check if the motor needs to move
                        {
                            // move to X posn.
                            if (StepperController.gotoHorizontal((long)(mes.Horizontal * 1000.0)) == false)
                            {
                                // error
                                Console.WriteLine("Horizontal Error");
                            }
                            while (StepperController.isBusy == true) // wait to complete
                            {
                                //System.Threading.Thread.Sleep(1000);
                                await Task.Delay(1000);
                            }
                        }


                        if (StepperController.yPositionmm != mes.Vertical) // check if the motor needs to move
                        {
                            //move to Y posn
                            if (StepperController.gotoVertical((long)(mes.Vertical * 1000.0)) == false)
                            {
                                // error
                                Console.WriteLine("Vertical Error");
                            }
                            while (StepperController.isBusy == true) // wait to complete.
                            {
                                await Task.Delay(1000);
                                //System.Threading.Thread.Sleep(1000);
                            }
                        }
                    }
                    if (this.isPaused == true) // are we paused?
                    {
                        Console.WriteLine("Paused");
                        while (isPaused == true) // are we still paused?
                        {
                            await Task.Delay(new TimeSpan(0, 0, 0, 3)); // wait 3 seconds
                        }
                        Console.WriteLine("Resuming");
                    }
                    // get seconds and milliseconds of the settle time.
                    int seconds = (int)mes.SettleTime;
                    int milliseconds = (int)((mes.SettleTime % 1) * 1000.0);

                    // System.Threading.Thread.Sleep(new TimeSpan(0, 0,0,seconds, milliseconds)); // wait for flow to settle.
                    await Task.Delay(new TimeSpan(0, 0, 0, seconds, milliseconds)); // wait the requested delay
                    PressureController.OutputData = new List<PressureData>(); // clear out the data fully.
                    HotWireController.OutputData = new List<HotWireData>(); // clear out the data fully
                    PressureController.RecordData = true; // set the flag to begin recording data
                    //  System.Threading.Thread.Sleep(new TimeSpan((long)(mes.MeasurementTime * 10.0))); // wait for the appropriate sample time.
                    await Task.Delay(new TimeSpan(0, 0, 0, seconds, milliseconds + 5)); // add a little to allow for the time for the property to update
                    PressureController.RecordData = false; //set the flag to stop recording data
                    try
                    {
                        // get the data from the controller
                        List<PressureData> Pressure = PressureController.OutputData.ToList();
                        // convert the data into time based data.
                        List<PressureExportData> Exportdata = PressureController.getExportData(Pressure, ref PressureMeasurementCount);
                        Console.WriteLine(Exportdata.Count() + " Readings Taken");
                        // get the average value for each sensor reading.
                        Pressure1Avg = Exportdata.Average(x => x.Pressure1);
                        Pressure2Avg = Exportdata.Average(x => x.Pressure2);
                        Pressure3Avg = Exportdata.Average(x => x.Pressure3);
                        Pressure4Avg = Exportdata.Average(x => x.Pressure4);
                        Pressure5Avg = Exportdata.Average(x => x.Pressure5);
                        Pressure6Avg = Exportdata.Average(x => x.Pressure6);
                        Pressure7Avg = Exportdata.Average(x => x.Pressure7);
                        Pressure8Avg = Exportdata.Average(x => x.Pressure8);
                        Pressure9Avg = Exportdata.Average(x => x.Pressure9);
                        Pressure10Avg = Exportdata.Average(x => x.Pressure10);

                        // a quick check to catch the sensor 4 issue.
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
                            // set the good reading flag.
                            goodReading = true;
                            break;
                        }
                    }
                    catch (Exception)
                    {
                        Console.WriteLine("ERROR");
                    }

                } // end while  - got reading.

                // add the measurement and the hot wire data to the measurement container.
                MeasurementData.Add(new AutomationMeasurement(mes.id, mes.Horizontal, mes.Vertical,Pressure1Avg, Pressure2Avg, Pressure3Avg,Pressure4Avg,Pressure5Avg, Pressure6Avg, Pressure7Avg,Pressure8Avg,Pressure9Avg,Pressure10Avg, HotWireController.OutputData.ToList())); // get a copy of the measurements.
                CompletedMeasurementCount++; // increment the measurement count.
            } // move to next measurement
            Console.WriteLine("Done!"); // we are done!
            if (AutomationCompletedEvent != null)
                AutomationCompletedEvent(); // trigger a notification to the user to show we are done!
        }
        #endregion
    }
}
