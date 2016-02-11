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
    public enum MotorDirection { none, left, right }
    public enum MotorSpeed { none, slow, fast, dynamic }
    public enum MotorAxis { none, x, y }
    public enum MotorStep { none, wave, half, full }

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
