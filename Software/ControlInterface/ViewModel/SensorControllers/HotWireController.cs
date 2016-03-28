using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Model;
using ViewModel.Helpers;

namespace ViewModel.SensorControllers
{
  public   class HotWireController : ViewModelBase
    {
        #region Properties + Data
        public List<HotWireData> OutputData = new List<HotWireData>();
        public double CurrentSensor1Reading
        { get; private set; } = 0;
        private ConnectionState _ConnectionState = ConnectionState.Disconnected;
        public ConnectionState ConnectionState
        {
            get
            {
                return _ConnectionState;
            }
            set
            {
                this.SetField(ref _ConnectionState, value, () => ConnectionState);
            }
        }
        private bool _isConnected = false;
        public bool isConnected
        {
            get
            {
                return _isConnected;
            }
            set
            {
                if (value == true)
                {
                    ConnectionState &= ~ConnectionState.Disconnected;
                    ConnectionState = ConnectionState | ConnectionState.Connected; // add the connected status.
                }
                else
                    ConnectionState = ConnectionState.Disconnected; // set the enum to this state solely.
                this.SetField(ref _isConnected, value, () => isConnected);
            }
        }
        #endregion
        

    }
}