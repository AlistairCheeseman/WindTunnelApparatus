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

        private void PressureDisconnect_Click(object sender, RoutedEventArgs e)
        {
            ((MenuViewModel)this.DataContext).DisconnectPressure();
        }
        private void PressureConnect_Click(object sender, RoutedEventArgs e)
        {
            ((MenuViewModel)this.DataContext).ConnectPressure();
        }
    }
}
