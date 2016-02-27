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
        public PressureData(long moment, decimal Pressure, decimal Temperature, ushort ErrorCode)
        {
            this.moment = moment;
            this.Pressure = Pressure;
            this.Temperature = Temperature;
            this.ErrorCode = ErrorCode;
        }
        public long moment { get; set; }
        public decimal Pressure { get; set; }
        public decimal Temperature { get; set; }
        public int ErrorCode { get; set; }
    }


}
