﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model
{
    /// <summary>
    ///  this file holds any custom structures & enums for the program
    /// </summary>
    /// 

        /* MOTOR ENUMS */
    public enum MotorDirection { none = 0, left = 1, right = 2 }
    public enum MotorSpeed { none = 0, fast = 1, slow = 2, dynamic = 3 }
    public enum MotorAxis { none = 0, x = 1, y = 2 }
    public enum MotorStep { none = 0, wave = 1, half = 2, full = 3 }

    /*ViewModel Connection States  - setting to powers of 2 and settings flags allows multiple values */
    [Flags]
    public enum ConnectionState {  none = 1, Connected = 2, Disconnected = 4, INIT = 8, Busy = 16}
    
    /* Pressure Data container */
    public class PressureData
    {
        public PressureData(long id, double Pressure, double Temperature, ushort ErrorCode, int sensorId, DateTime moment) 
        {
            this.id = id;
            this.Pressure = Pressure;
            this.Temperature = Temperature;
            this.ErrorCode = ErrorCode;
            this.sensorId = sensorId;
            this.moment = moment;
        }
        public long id { get; set; }
        public double Pressure { get; set; }
        public double Temperature { get; set; }
        public int ErrorCode { get; set; }
        public int sensorId { get; set; }
        public DateTime moment { get; set; }
    }
    /* Hot Wire Data container - very basic data due to the analog nature of the device. */
    public class HotWireData
    {
        public HotWireData(long id, double measurement, DateTime moment)
        {
            this.id = id;
            this.measurement = measurement;
            this.moment = moment;
        }
        public long id { get; set; }
        public double measurement { get; set; }
        public DateTime moment { get; set; }
    }
    /* container to hold the measurements for a set position */
    public class AutomationMeasurement
    {
        public AutomationMeasurement(long _id, double _posnHoriz, double _posnVert,
            double _Pressure1Avg,
             double _Pressure2Avg,
              double _Pressure3Avg,
               double _Pressure4Avg,
                double _Pressure5Avg,
                 double _Pressure6Avg,
                  double _Pressure7Avg,
                   double _Pressure8Avg,
                    double _Pressure9Avg,
                     double _Pressure10Avg,
            List<HotWireData> _hotWire)
        {
            this.id = _id;
            this.PosnHoriz = _posnHoriz;
            this.PosnVert = _posnVert;
            this.Pressure1Avg = _Pressure1Avg;
            this.Pressure2Avg = _Pressure2Avg;
            this.Pressure3Avg = _Pressure3Avg;
            this.Pressure4Avg = _Pressure4Avg;
            this.Pressure5Avg = _Pressure5Avg;
            this.Pressure6Avg = _Pressure6Avg;
            this.Pressure7Avg = _Pressure7Avg;
            this.Pressure8Avg = _Pressure8Avg;
            this.Pressure9Avg = _Pressure9Avg;
            this.Pressure10Avg = _Pressure10Avg;
            this.HotWireReadings = _hotWire;
        }
       public double Pressure1Avg
        {
            get; set;
        }
      public double Pressure2Avg
        {
            get; set;
        }
        public double Pressure3Avg { get; set; }
        public double Pressure4Avg { get; set; }
        public double Pressure5Avg { get; set; }
        public double Pressure6Avg { get; set; }
        public double Pressure7Avg { get; set; }
        public double Pressure8Avg { get; set; }
        public double Pressure9Avg { get; set; }
        public double Pressure10Avg { get; set; }
        public List<HotWireData> HotWireReadings { get; set; }
        public double PosnHoriz { get; set; }
        public double PosnVert { get; set; }
        public long id { get; set; }

    }
    /* this class holds the list of positions to autoamtically measure, how long to measure etc */
    public class Measurement
    {
        public int id;
        public double Vertical;
        public double Horizontal;
        public double MeasurementTime;
        public double SettleTime;
    }
    /* Pressure Exporter class */
    public class PressureExportData
    {
        public long id;
        public DateTime moment;
        public double Pressure1;
        public double Temperature1;
        public double Pressure2;
        public double Temperature2;
        public double Pressure3;
        public double Temperature3;
        public double Pressure4;
        public double Temperature4;
        public double Pressure5;
        public double Temperature5;
        public double Pressure6;
        public double Temperature6;
        public double Pressure7;
        public double Temperature7;
        public double Pressure8;
        public double Temperature8;
        public double Pressure9;
        public double Temperature9;
        public double Pressure10;
        public double Temperature10;
    }


}
