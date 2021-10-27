import pandas as pd
from matplotlib import pyplot as plt
from plotly import graph_objs as go
from plotly.offline import init_notebook_mode, iplot
init_notebook_mode(connected=True)
import math as ma

''' Class Analyse config details

==> List of all available functions (COULD BE MADE PRIVATE AS PER USER's WISH)

- __init__(path, no_of_decisions, titles)
- get_all_runs_data()
- get_individual_run_data(raw_data)
- normalise_data()
- get_line_plot(title_for_plot)
- get_data_for_bar_plot(width)
- get_bar_plot(title_for_plot, width)
- get_data_for_moving_avg_plot()
- get_moving_average_plot(title_for_plot, interval):

'''

# takes in individual dataset, modifies the data suitable to plotting and produces various plots
class Analyse:
    
# START OF __init__ FUNCTION

    # constructor that loads the dataset and gets everything ready for analysing
    def __init__(self, path, no_of_decisions, titles):
        
        # initial no_of_decisions, useful at the normalisation stage
        self.no_of_decisions = no_of_decisions
        
        # initialise the titles for all the data 
        if len(titles) != self.no_of_decisions:
            self.titles = ["D" + str(i+1) for i in range(self.no_of_decisions)]
        else:
            self.titles = titles

        # read in the raw from the data provided by the user
        self.data = pd.read_csv(path, low_memory=False)
        
        # get the number of columns from the raw data to evaluate the total number of runs
        self.total_runs = self.data.shape[1] - 1
        
        # get the formatted version for all the runs that could be used to plot the data
        self.line_plot_data = self.get_all_runs_data()
        
        # normalise the data 
        self.normalise_data()
        
#-----------------------------------------------------------------------------------------------------------#

# START OF get_all_runs_data FUNCTION
    
 # function to filter and receive data for each individual run
    def get_all_runs_data(self):
        
        # empty array that is to be returned
        all_runs_data = []
        
        # for loop to get all the values
        for col in range(self.total_runs):
            
            #[THIS BIT REQUIRED SOME HARDCODING]
            DATA_START_POINT = 12 # this is where the data starts in the csv file
            
            
            # send in the data for the corresponding run (column) 
            run_data = self.get_individual_run_data(self.data[str(col+1)][DATA_START_POINT:])
            
            # append run data to final array
            all_runs_data.append(run_data)
        
        # return the array wherever it was called
        return all_runs_data
    
#-----------------------------------------------------------------------------------------------------------#
    
# START OF get_individual_run_data FUNCTION

    # function to filter and compress data into a sensible format using for plotting
    def get_individual_run_data(self, raw_data):

        # [0 1 1 1 3 3 7 7 8 8 8 8 NaN NaN NaN NaN] -> [0 1 3 7 8] (Quick example for what this function does)
        
        # Code to remove NaNs from the data (default values if the cell in the csv file is empty)
        
        # empty array which is to be used for part B of this function
        run_data = []

        # filter the run_data array to not have NaN values
        for val in raw_data:
            if ma.isnan(val): break # get out the first time we encounter a NaN value
            
            # Or else append the value in int type to our new array
            run_data.append(int(val))

        # Removing NaNs from data complete here
                
        # Code to convert the raw data into format that mimics at what distance you were at a particular lane change
        
        # array that is to be returned at the end
        run_lane_change_data = [0]
        prev = 0 # prev variable to store everytime the value is changed
        
        # traverse through the run_data to convert to the required form
        for val in run_data:
            if prev != val:
                run_lane_change_data.append(val)
                prev = val # update the previous variable
                
        # return the processed data for the run
        return run_lane_change_data
    
#-----------------------------------------------------------------------------------------------------------#
   
# START OF normalise_data FUNCTION

    # function to normalise the data to individual decisions
    def normalise_data(self):
        
        # EXAMPLE: here each element represents the decision used for that run (which is an entire row)
        # [1 1 1 1 2 2 2 2 3 3 3 3 4 4 4 4] -> [1 2 3 4] 
        # {all the data for runs is averaged out and compressed into one row for each decision}
        
        # get the maximum value of the columns present in a row
        max_elements_in_row = max( [len(row) for row in self.line_plot_data] )
        
        # go through all the data and add zeros to smaller rows to make the dimensions equal
        for i in range(len(self.line_plot_data)):
            self.line_plot_data[i] += ( [self.line_plot_data[i][-1]] * ( max_elements_in_row - len(self.line_plot_data[i]) ) )
        
        # get the window size of how many runs used a certain decision
        size_of_runs_per_decision = len(self.line_plot_data) // self.no_of_decisions
        
        # calculate the total number of lane changes (which will be the number of columns in any row of the processed data)
        number_of_lane_changes = len(self.line_plot_data[0])

        normalised_data = [ 
            [0] * number_of_lane_changes for _ in range(self.no_of_decisions)
        ]
        
        # traverse through all the decisions and feed in the normalised values into specific indexes

        # for each individual decision
        for decision_idx in range(self.no_of_decisions): 
            
            # for each run that used that decision
            for each_run_idx in range(size_of_runs_per_decision): 
                
                # for all the individual lane changes 
                for idx, val in enumerate(self.line_plot_data[decision_idx * size_of_runs_per_decision + each_run_idx]):
                    
                    # add the normalised data [division by size_of_runs_per_decision is basically calculating the mean]
                    normalised_data[decision_idx][idx] += (val / size_of_runs_per_decision)   
        
        # equate it back to line plot data so that now the user can just see the normalised plot
        self.line_plot_data = normalised_data
        
        return 
    
#-----------------------------------------------------------------------------------------------------------#
   
# START OF get_line_plot FUNCTION
    
    # function to generate a line plot for the data processed earlier
    def get_line_plot(self, title_for_plot):

        # get the x-coordinates for the plot
        self.xcords = [i for i in range(len(self.line_plot_data[0]))]
        
        # plot individual decisions
        for idx, row in enumerate(self.line_plot_data):
            plt.plot(row, self.xcords, label = self.titles[idx])
        
        # code for plotting a graph using pyplot
        plt.xlim(left=0)
        plt.ylim(bottom=0)
        fs = 18
        plt.title(title_for_plot, fontsize=fs+2)
        plt.xlabel("Distance Covered", fontsize=fs)
        plt.ylabel("No. of Lane Changes", fontsize=fs)
        plt.savefig("images/Line Plot --> " + title_for_plot + ".png")
        plt.legend()
        plt.show()
        
        # return the plot in case the user wants to do something with it
        return plt
    
#-----------------------------------------------------------------------------------------------------------#
   
# START OF get_data_for_bar_plot FUNCTION
    
    # function to get data for bar plot
    def get_data_for_bar_plot(self, width):
        
        # empty array that is returned 
        bar_plot_data = []
        
        # previous value
        prev = 0
        
        # traverse through the processed data
        for row in self.line_plot_data:
            
            # temporary array to store answers for all individual decisions
            decision = []
            
            # threshold is initialised to interval at the start
            threshold = width
            
            # traverse through the individual lane 
            for i, val in enumerate(row):
                
                # feed in the data when a threshold is hit suggesting that 
                if val > threshold:
                    
                    # get the average distance travelled for that number of lane changes 
                    if i - prev - 1 != 0 and (row[i-1] > row[prev]):
                        decision.append( (row[i-1] - row[prev]) / (i - prev - 1) ) # equation 1.1 for ref
                    else:
                        decision.append(row[i]-row[i-1])
                        
                    # update the variable for the next range
                    prev = i
                    threshold += width
            
            # append the decision to the data
            bar_plot_data.append(decision)
        
        # code to make sure that the dimensions are correct for all decisions
        
        # get the maximum value of the columns present in a row
        max_elements_in_row = max( [len(row) for row in bar_plot_data] )
        
        # go through all the data and add zeros to smaller rows to make the dimensions equal
        for i in range(len(bar_plot_data)):
            
            bar_plot_data[i] += ( [bar_plot_data[i][-1]] * ( max_elements_in_row - len(bar_plot_data[i]) ) )
            
        # return the bar plot data to where the function is called
        return bar_plot_data
    
#-----------------------------------------------------------------------------------------------------------#
   
# START OF get_bar_plot FUNCTION 
    
    # function to generate a bar plot to compare the avg lane changed done by decisions from the given interval
    def get_bar_plot(self, title_for_plot, width):
        
        # function to get the data suitable for the bar plot
        data = self.get_data_for_bar_plot(width)
        
        # initialise a dictionary to store all the data in
        bar_plot_data = {}
        
        # generate titles for x-axis
        x_axis_titles = [ str(i* width)+" - "+str((i + 1) * width) for i in range(len(data[0])) ]
        
        # tranform the data in 2-D array to dictionary for pyplot to able to read it properly
        for idx, each_decision in enumerate(data):
            bar_plot_data[self.titles[idx]] = each_decision
        
        # code for plotting a graph using pyplot
        plotdata = pd.DataFrame(bar_plot_data, index = x_axis_titles)
        plotdata.plot(kind="bar")
        plotdata.head()
        fs = 18 # font size
        plt.title(title_for_plot, fontsize=fs+2)
        plt.xlabel("Intervals", fontsize=fs)
        plt.ylabel("Moving Average", fontsize=fs)
        plt.savefig("images/Bar Plot --> " + title_for_plot + ".png")
        plt.legend()
        plt.show()
        
        # return the plot in case the user wants to do something with it
        return plotdata
    
#-----------------------------------------------------------------------------------------------------------#
   
# START OF get_data_for_moving_plot FUNCTION
    
    # function to return data that could be plotted using a moving average plot
    def get_data_for_moving_avg_plot(self):
        
        # empty array that is returned 
        moving_avg_plot_data = []
        
        # traverse through the line plot data
        for row in self.line_plot_data:
            
            # temporary array to store answers for all individual decisions
            decision = [0 for _ in range(len(row)-1)] 
            
            # store the differences between consecutive elements to 
            # to record the distance travelled in b/w those lanes
            for j in range(1, len(row)):
                decision[j-1] =  row[j] - row[j-1] 
                if (row[j] < row[j-1]): print(row[j], row[j-1])

            # append that array to the final returning variable
            moving_avg_plot_data.append(decision)
        
        # return the moving avg plot data to where the function is called
        return moving_avg_plot_data

#-----------------------------------------------------------------------------------------------------------#
   
# START OF get_moving_avg_plot FUNCTION
    
    # function to generate a moving average plot to
    # evaluate the decisions based on the avg distance travelled by them in the given interval
    def get_moving_average_plot(self, title_for_plot, interval):
        
        # function to get the data suitable for the moving avg plot
        data = self.get_data_for_moving_avg_plot()
        
        # initialise a dictionary to store all the data in
        moving_avg_plot_data = {}
        
        # tranform the data in 2-D array to dictionary for pyplot to able to read it properly
        for idx, each_decision in enumerate(data):
            moving_avg_plot_data[self.titles[idx] + "temp"] = each_decision
        
        # code for plotting a graph using pyplot
        plotdata = pd.DataFrame(moving_avg_plot_data)
        
        # generate the data for moving avg given the interval
        for i in range(self.no_of_decisions):
            plotdata[self.titles[i]] = plotdata.iloc[:, i].rolling(window=interval).mean()
            
        # delete the previous data to only plot the moving avg data
        for idx, each_decision in enumerate(data):
            del plotdata[self.titles[idx] + "temp"]

        plotdata.plot(kind="line")
        fs = 18 # font size
        plt.title(title_for_plot, fontsize=fs+2)
        plt.xlabel("No. of Lane Changes", fontsize=fs)
        plt.ylabel("Moving Avg", fontsize=fs)
        plt.savefig("images/Moving Avg Plot --> " + title_for_plot + ".png")
        
        # return the plot in case the user wants to do something with it
        return plotdata
    
#-----------------------------------------------------------------------------------------------------------#
 
  