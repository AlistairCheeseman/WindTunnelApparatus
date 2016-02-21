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

    /*ViewModel Connection States */
    public enum ConnectionState {  none, ConnectedREADY, ConnectedINIT, ConnectedBusy}

    /* Pressure Data container */
    public class PressureData
    {
        public PressureData(double X, decimal Y)
        {
            this.x = X;
            this.y = Y;
        }
        public double x { get; set; }
        public decimal y { get; set; }
    }


}
