using System;
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
        public AutomationMeasurement(long _id, double _posnHoriz, double _posnVert, List<PressureData> _pressure, List<HotWireData> _hotWire)
        {
            this.id = _id;
            this.PosnHoriz = _posnHoriz;
            this.PosnVert = _posnVert;
            this.PressureReadings = _pressure;
            this.HotWireReadings = _hotWire;
        }
        public List<PressureData> PressureReadings { get; set; }
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
    }

}
