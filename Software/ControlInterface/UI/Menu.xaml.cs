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
using System.ComponentModel;
using ViewModel.SensorControllers;
using ViewModel.Helpers;
using Model;


namespace UI
{
    /// <summary>
    /// Interaction logic for Menu.xaml
    /// </summary>
    public partial class Menu : Window
    {
        public Menu(ref MenuViewModel viewModel)
        {
            InitializeComponent();
            this.DataContext = viewModel;
            viewModel.AutomationCompletedEvent += ViewModel_AutomationCompletedEvent;
        }

        private void ViewModel_AutomationCompletedEvent()
        { // the automation is completed. prompt to ask for save location.
            MessageBox.Show("Measurement Completed, Please select folder and file Prefix to save results.");
            Microsoft.Win32.SaveFileDialog SFD = new Microsoft.Win32.SaveFileDialog();
            SFD.FileName = "AutomationExport-";
            //SFD.DefaultExt = ".csv";
            //SFD.Filter = "Comma Separated Values (.csv)|*.csv";
            SFD.ShowDialog();
           long ExportedRecordCount =  ((MenuViewModel)this.DataContext).ExportAll(SFD.FileName);
            MessageBox.Show(ExportedRecordCount.ToString() + " Measurements Sucessfully Exported");
        }

        private void PressureConnectDisconnect_Click(object sender, RoutedEventArgs e)
        {
            if (!((MenuViewModel)this.DataContext).AutomationController.PressureController.isConnected)
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
            if (!((MenuViewModel)this.DataContext).AutomationController.StepperController.isConnected)
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
            if (!((MenuViewModel)this.DataContext).AutomationController.HotWireController.isConnected)
            {
                ((MenuViewModel)this.DataContext).ConnectHotWire();
            }
            else
            {
                ((MenuViewModel)this.DataContext).DisconnectHotWire();
            }
        }
        private void HotWireExport_Click(object sender, RoutedEventArgs e)
        {
            Microsoft.Win32.SaveFileDialog SFD = new Microsoft.Win32.SaveFileDialog();
            SFD.FileName = "HotwireExport";
            SFD.DefaultExt = ".csv";
            SFD.Filter = "Comma Separated Values (.csv)|*.csv";
            SFD.ShowDialog();
            ((MenuViewModel)this.DataContext).ExportHotWire(SFD.FileName);
        }
        private void PressureExport_Click(object sender, RoutedEventArgs e)
        {
            Microsoft.Win32.SaveFileDialog SFD = new Microsoft.Win32.SaveFileDialog();
            SFD.FileName = "PressureExport";
            SFD.DefaultExt = ".csv";
            SFD.Filter = "Comma Separated Values (.csv)|*.csv";
            SFD.ShowDialog();
            ((MenuViewModel)this.DataContext).ExportPressure(SFD.FileName);
        }
        private void StepLeft_Click(object sender, RoutedEventArgs e)
        {
            ((MenuViewModel)this.DataContext).StepLeft();
        }
        private void StepRight_Click(object sender, RoutedEventArgs e)
        {
            ((MenuViewModel)this.DataContext).StepRight();
        }
        private void StepUp_Click(object sender, RoutedEventArgs e)
        {
            ((MenuViewModel)this.DataContext).StepUp();
        }
        private void StepDown_Click(object sender, RoutedEventArgs e)
        {
            ((MenuViewModel)this.DataContext).StepDown();
        }

        private void stimulusMenuBtn_Click(object sender, RoutedEventArgs e)
        {
            // create and display the stimulus generator form.
            UI.StimulusGenerator SG = new StimulusGenerator();
            SG.ShowDialog();
        }

        private void LoadStimulusBtn_Click(object sender, RoutedEventArgs e)
        {
            Microsoft.Win32.OpenFileDialog OFD = new Microsoft.Win32.OpenFileDialog();
            OFD.FileName = "";
            OFD.DefaultExt = ".csv";
            OFD.Filter = "Comma Separated Values (.csv)|*.csv";
            if (OFD.ShowDialog() == false)
            {
                // succesful file selection.
                MessageBox.Show("Couldn't access the stimulus file.");
            }
            else
            {
                ((MenuViewModel)this.DataContext).LoadStimulus(OFD.FileName);
            }
        }

        private async void GoBtn_Click(object sender, RoutedEventArgs e)
        {
            //  ((MenuViewModel)this.DataContext).ExecuteMeasurementCycle();
          await  ((MenuViewModel)this.DataContext).AutomationController.Automate();
        }
    }
}
