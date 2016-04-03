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

namespace UI
{
    /// <summary>
    /// Interaction logic for StimulusGenerator.xaml
    /// </summary>
    public partial class StimulusGenerator : Window
    {
        public StimulusGenerator()
        {
            InitializeComponent();
            horizontalminTxt.Text = "-150";
            horizontalmaxTxt.Text = "150";
            verticalminTxt.Text = "-150";
            verticalmaxTxt.Text = "150";
        }

        private void GenerateBtn_Click(object sender, RoutedEventArgs e)
        {
            // this should be moved to a view model but as this is so simple no need to overcomplicate.
            double horizontalmin, horizontalmax, verticalmin, verticalmax, settleTime, stepDistance, measurementDuration;
            if (double.TryParse(horizontalminTxt.Text, out horizontalmin) == false)
            {
                MessageBox.Show("Error parsing horizontal min, please check that only numbers are present.");
                return;
            }
            if (double.TryParse(horizontalmaxTxt.Text, out horizontalmax) == false)
            {
                MessageBox.Show("Error parsing horizontal max, please check that only numbers are present.");
                return;
            }
            if (double.TryParse(verticalminTxt.Text, out verticalmin) == false)
            {
                MessageBox.Show("Error parsing vertical min, please check that only numbers are present.");
                return;
            }
            if (double.TryParse(verticalmaxTxt.Text, out verticalmax) == false)
            {
                MessageBox.Show("Error parsing vertical max, please check that only numbers are present.");
                return;
            }
            if (double.TryParse(PeriodTxt.Text, out measurementDuration) == false)
            {
                MessageBox.Show("Error parsing measurement period, please check that only numbers are present.");
                return;
            }
            if (double.TryParse(SettleDurationTxt.Text, out settleTime) == false)
            {
                MessageBox.Show("Cannot parse settle time.");
                return;
            }
            if (double.TryParse(StepTxt.Text, out stepDistance) == false)
            {
                MessageBox.Show("Error parsing step %, please check that only numbers are present.");
                return;
            }

            int StepCount = (int)(100.0 / stepDistance) + 1;
            double ActualStepHorizontal = (Math.Abs(horizontalmin - horizontalmax)) * (stepDistance / 100); // get the distance from zero and add together, then * by the % step. 
            double ActualStepVertical = (Math.Abs(verticalmin - verticalmax)) * (stepDistance / 100); // get the distance from zero and add together, then * by the % step. 

            StringBuilder SB = new StringBuilder();
            SB.AppendLine("id, Horizontal,Vertical,Measurement Duration,SettleTime");
            long id = 0;
            double Horizontal, Vertical;
            // intialise to the top left hand corner.
            Horizontal = horizontalmin;
            Vertical = verticalmax + ActualStepVertical;
         

            if (RasterVerticalOption.IsChecked == true)
            {
                for (int t = 1; t <= StepCount; t++)
                {
                    for (int u = 1; u <= StepCount; u++)
                    {
                        Vertical = Vertical - ActualStepVertical;
                        SB.AppendLine(string.Format("{0},{1},{2},{3},{4}", id, Horizontal, Vertical, measurementDuration, settleTime));
                        id++;
                    }
                    Horizontal = Horizontal + ActualStepHorizontal;
                    Vertical = verticalmax + ActualStepVertical;
                }
            }
            else if (RasterVerticalOption.IsChecked == true)
            {
                for (int t = 1; t <= StepCount; t++)
                {
                    for (int u = 1; u <= StepCount; u++)
                    {
                        Horizontal = Horizontal + ActualStepHorizontal;
                        SB.AppendLine(string.Format("{0},{1},{2},{3},{4}", id, Horizontal, Vertical, measurementDuration, settleTime));
                        id++;
                    }
                    Vertical = Vertical - ActualStepVertical;
                    Horizontal = horizontalmin - ActualStepHorizontal;
                }
            }
            else
            {
                MessageBox.Show("Please enter scan method.");
                return;
            }
            // finally write the file.
            Microsoft.Win32.SaveFileDialog SFD = new Microsoft.Win32.SaveFileDialog();
            SFD.FileName = "Stimulus";
            SFD.DefaultExt = ".csv";
            SFD.Filter = "Comma Separated Values (.csv)|*.csv";
            if (SFD.ShowDialog() == true)
            {
                System.IO.File.WriteAllText(SFD.FileName, SB.ToString());
                MessageBox.Show(String.Format("File written to \r\n{0}", SFD.FileName));
            }
        }
    }
}
