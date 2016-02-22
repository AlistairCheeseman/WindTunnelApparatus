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
using System.Windows.Shapes;
using ViewModel;

namespace UI
{
    /// <summary>
    /// Interaction logic for Menu.xaml
    /// </summary>
    public partial class Menu : Window
    {
        public Menu( ref MenuViewModel viewModel)
        {
            InitializeComponent();
            this.DataContext = viewModel;
        }

  
        private void PressureConnectDisconnect_Click(object sender, RoutedEventArgs e)
        {
            if (!((MenuViewModel)this.DataContext).PressureController.isConnected)
            {
                ((MenuViewModel)this.DataContext).ConnectPressure();
            }
            else
            {
                ((MenuViewModel)this.DataContext).DisconnectPressure();
            }
           
        }
        private void StepperConnectDisconnect_Click(object sender, RoutedEventArgs e)
        {
            if (!((MenuViewModel)this.DataContext).StepperController.isConnected)
            {
                ((MenuViewModel)this.DataContext).ConnectStepper();
            }
            else
            {
                ((MenuViewModel)this.DataContext).DisconnectStepper();
            }
        }
        private void HotWireConnectDisconnect_Click(object sender, RoutedEventArgs e)
        {

        }
        private void HotWireExport_Click(object sender, RoutedEventArgs e)
        {

        }
        private void PressureExport_Click(object sender, RoutedEventArgs e)
        {

        }
        private void StepLeft_Click(object sender, RoutedEventArgs e)
        {
            ((MenuViewModel)this.DataContext).StepLeft();
        }
    }
}
