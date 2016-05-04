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
    /// Interaction logic for Menu.xaml, simply wires up the buttons to the viewmodel fuctions.
    /// </summary>
    public partial class Menu : Window
    {
        public Menu(ref MenuViewModel viewModel)
        {
            InitializeComponent();
            this.DataContext = viewModel; // assign the view model to the data context of the view.
            viewModel.AutomationCompletedEvent += ViewModel_AutomationCompletedEvent; // add an event handler for when the automation is completed.
        }

        private void ViewModel_AutomationCompletedEvent()
        { // the automation is completed. prompt to ask for save location.
            MessageBox.Show("Measurement Completed, Please select folder and file Prefix to save results.");
            Microsoft.Win32.SaveFileDialog SFD = new Microsoft.Win32.SaveFileDialog();
            SFD.FileName = "AutomationExport-";
            //SFD.DefaultExt = ".csv";
            //SFD.Filter = "Comma Separated Values (.csv)|*.csv";
            SFD.ShowDialog();
            // actually ask the view model to export the data to the given file path.
           long ExportedRecordCount =  ((MenuViewModel)this.DataContext).ExportAll(SFD.FileName);
            MessageBox.Show(ExportedRecordCount.ToString() + " Measurements Sucessfully Exported");
        }

        private void PressureConnectDisconnect_Click(object sender, RoutedEventArgs e)
        {
            // if it is already connected, disconnect it.
            if (!((MenuViewModel)this.DataContext).AutomationController.PressureController.isConnected)
            {
                ((MenuViewModel)this.DataContext).ConnectPressure(); // connect
            }
            else
            {
                ((MenuViewModel)this.DataContext).DisconnectPressure(); //disconnect
            }

        }
        private void StepperConnectDisconnect_Click(object sender, RoutedEventArgs e)
        {
            // if it is already connected, disconnect it.
            if (!((MenuViewModel)this.DataContext).AutomationController.StepperController.isConnected)
            {
                ((MenuViewModel)this.DataContext).ConnectStepper(); //connect
            }
            else
            {
                ((MenuViewModel)this.DataContext).DisconnectStepper(); //disconnect
            }
        }
        private void HotWireConnectDisconnect_Click(object sender, RoutedEventArgs e)
        {
            // if it is already connected, disconnect it.
            if (!((MenuViewModel)this.DataContext).AutomationController.HotWireController.isConnected)
            {
                ((MenuViewModel)this.DataContext).ConnectHotWire(); //connect
            }
            else
            {
                ((MenuViewModel)this.DataContext).DisconnectHotWire(); //disconnect
            }
        }
        private void HotWireExport_Click(object sender, RoutedEventArgs e)
        {
            //export the hot wire data to the requested location
            Microsoft.Win32.SaveFileDialog SFD = new Microsoft.Win32.SaveFileDialog();
            SFD.FileName = "HotwireExport";
            SFD.DefaultExt = ".csv";
            SFD.Filter = "Comma Separated Values (.csv)|*.csv";
            SFD.ShowDialog();
            //request the export
            ((MenuViewModel)this.DataContext).ExportHotWire(SFD.FileName);
        }
        private void PressureExport_Click(object sender, RoutedEventArgs e)
        {
            Microsoft.Win32.SaveFileDialog SFD = new Microsoft.Win32.SaveFileDialog();
            SFD.FileName = "PressureExport";
            SFD.DefaultExt = ".csv";
            SFD.Filter = "Comma Separated Values (.csv)|*.csv";
            SFD.ShowDialog();
            //request the export
            ((MenuViewModel)this.DataContext).ExportPressure(SFD.FileName);
        }
        private void StepLeft_Click(object sender, RoutedEventArgs e)
        {
            //nudge left
            ((MenuViewModel)this.DataContext).StepLeft();
        }
        private void StepRight_Click(object sender, RoutedEventArgs e)
        {
            //nudge right
            ((MenuViewModel)this.DataContext).StepRight();
        }
        private void StepUp_Click(object sender, RoutedEventArgs e)
        {
            //nudge up
            ((MenuViewModel)this.DataContext).StepUp();
        }
        private void StepDown_Click(object sender, RoutedEventArgs e)
        { //nudge down
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
            // get the file from the user and ask the view model to load the stimulus file
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
                //go!
                ((MenuViewModel)this.DataContext).LoadStimulus(OFD.FileName);
            }
        }

        private async void GoBtn_Click(object sender, RoutedEventArgs e)
        {
            //  ((MenuViewModel)this.DataContext).ExecuteMeasurementCycle();
            //actually run the automation process
          await  ((MenuViewModel)this.DataContext).AutomationController.Automate();
        }
        private void PauseBtn_Click(object sender, RoutedEventArgs e)
        {
            // pause the current ruinning automation measurements.
            bool isCurrentlyPaused = ((MenuViewModel)this.DataContext).AutomationController.isPaused;
            isCurrentlyPaused = !isCurrentlyPaused;
            ((MenuViewModel)this.DataContext).AutomationController.isPaused = isCurrentlyPaused;
        }
    }
}
