using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Navigation;
using System.Windows.Shapes;
using Model;
using System.Collections.ObjectModel;
using System.Windows.Threading;

namespace UI
{
    /// <summary>
    /// Interaction logic for Charter.xaml
    /// </summary>
    public partial class Charter : Page
    {
        public delegate void MyDelegate(string inData);
        public Charter(ref ObservableCollection<PressureData> Data)
        {
            InitializeComponent();
            lineChart.DataContext = Data;  
        }
    }
}
