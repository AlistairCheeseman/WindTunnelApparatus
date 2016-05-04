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
            // here the default values are set, this is just to speed things along when in a rush or doing the same measurement a lot.
            horizontalminTxt.Text = "-79";
            horizontalmaxTxt.Text = "79";
            verticalminTxt.Text = "-79";
            verticalmaxTxt.Text = "79";
            PeriodTxt.Text = "100";
            SettleDurationTxt.Text = "5";
            StepTxt.Text = "10";
            RasterVerticalOption.IsChecked = true;
        }

        private void GenerateBtn_Click(object sender, RoutedEventArgs e)
        {
            // this should be moved to a view model but as this is so simple no need to overcomplicate.
            double horizontalmin, horizontalmax, verticalmin, verticalmax, settleTime, stepDistance, measurementDuration;

            // parse all the values and check they are good.
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

            // find howmany steps we will be moving.
            int StepCount = (int)(100.0 / stepDistance) + 1;
            // find out how big the steps will be
            double ActualStepHorizontal = (Math.Abs(horizontalmin - horizontalmax)) * (stepDistance / 100); // get the distance from zero and add together, then * by the % step. 
            double ActualStepVertical = (Math.Abs(verticalmin - verticalmax)) * (stepDistance / 100); // get the distance from zero and add together, then * by the % step. 
            
            StringBuilder SB = new StringBuilder(); // a container for the exported data until it is written to a file.
            SB.AppendLine("id, Horizontal,Vertical,Measurement Duration,SettleTime"); // write the header to the file
            long id = 0; // a unique number for each step.
            double Horizontal, Vertical; // container for the current progress.
            // intialise to the top left hand corner.

            //determine which raster direction we are working on to perform the appropriate calculations
            if (RasterVerticalOption.IsChecked == true) 
            {
                //set initial conditions for the position
                Horizontal = horizontalmin; 
                Vertical = verticalmax + ActualStepVertical;
                //for every horizontal line.
                for (int t = 1; t <= StepCount; t++)
                {
                    //for every vertial point on the line
                    for (int u = 1; u <= StepCount; u++)
                    {
                        // move the vertical point along a step.
                        Vertical = Vertical - ActualStepVertical;
                        //write the values
                        SB.AppendLine(string.Format("{0},{1},{2},{3},{4}", id, Horizontal, Vertical, measurementDuration, settleTime));
                        id++; // update the id
                    }
                    Horizontal = Horizontal + ActualStepHorizontal; // move to a new line
                    Vertical = verticalmax + ActualStepVertical; // reset the vertical position
                }
            }
            else if (RasterHorizontalOption.IsChecked == true)
            {
                //set initial conditions for the position
                Vertical = verticalmax;
                Horizontal = horizontalmin - ActualStepHorizontal;
                //for every vertical line.
                for (int t = 1; t <= StepCount; t++)
                {
                    //for every horizontal point on the line
                    for (int u = 1; u <= StepCount; u++)
                    {
                        //move the horizontal point along
                        Horizontal = Horizontal + ActualStepHorizontal;
                        //write the data
                        SB.AppendLine(string.Format("{0},{1},{2},{3},{4}", id, Horizontal, Vertical, measurementDuration, settleTime));
                        id++; //update the id
                    }
                    Vertical = Vertical - ActualStepVertical; //move to the next line
                    Horizontal = horizontalmin - ActualStepHorizontal; // reset the horizontal poition
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
                //write the text
                System.IO.File.WriteAllText(SFD.FileName, SB.ToString());
                //let the user know we are done!
                MessageBox.Show(String.Format("File written to \r\n{0}", SFD.FileName));
            }
        }
    }
}
