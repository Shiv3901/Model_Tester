import pandas as pd
from matplotlib import pyplot as plt
from plotly import graph_objs as go
from plotly.offline import init_notebook_mode, iplot
init_notebook_mode(connected=True)
import math as ma

class Analyse:

    # constructor that loads the dataset and gets everything ready for analysing
    def __init__(self, path, decisions):

        # initial no_of_decisions, useful at the normalisation stage
        self.no_of_decisions = decisions
        
        # read in the data
        self.data = pd.read_csv(path, low_memory=False)
        
        # get the number of columns which are the number of runs done for analysis
        self.cols = self.data.shape[1] - 1
        
        # get a dictionary of all the characteristics avaiables (basically they are all variables)
        self.characteristics = self.get_characteristics()
        
        # get the formatted version that could be used to plot the data
        self.lane_data_temp = self.get_all_lanes_data()
        self.filter_all_data()
        
        # array for the number of turns (right now the only variable for testing)
        self.turns = []
        
#         print(path)
    
    # function to return the values (characteristics) in a fom of dictionary
    def get_characteristics(self):
        
        # dictionary to store all the values
        values = {}
        
        # for loop to loop to those variables
        for col in range(self.cols):
            temp = {}
            
            key_data = self.data["[run number]"][:6]
            temp_data = self.data[str(col+1)][:6]
            
            for key in range(5):
                temp[key_data[key]] = temp_data[key]
                
            values[col+1] = temp
        
        return values
    
    # function to get all the lanes data in a plottable format
    def get_all_lanes_data(self):
        
        # empty array that is to be returned
        values = []
        
        # for loop to get all the values
        for col in range(self.cols):
            
            # send in the data for the corresponding column
            temp_arr = self.get_array(self.data[str(col+1)][12:])
            values.append(temp_arr)
        
        return values
    
    def modify(self, data):
        
        max_elements = max([len(row) for row in data])
        
        for i in range(len(data)):
            
            for j in range(max_elements - len(data[i])):
                
                data[i].append(data[i][-1])
                
        return data
    
    # function to average out the runs from the data
    def filter_all_data(self):
        
        size_of_runs = len(self.lane_data_temp) // self.no_of_decisions
        
        values = self.modify(self.lane_data_temp)
        number_of_lane_changes = len(self.lane_data_temp[0])

        new_values = [ 
            [0] * number_of_lane_changes for _ in range(self.no_of_decisions)
        ]
        
        # code to update the new values array
        
        for i in range(self.no_of_decisions):
            
            for k in range(size_of_runs):
                
                for idx, val in enumerate(values[i * size_of_runs + k]):
                    
                    new_values[i][idx] += (val / size_of_runs)
                
        self.lane_data_temp = new_values
                
            
   # function to get a single array in the required version
    def get_array(self, data):

        # empty array which is to be returned
        array = []

        for val in data: 
            array.append(val)

        # get all the values that are not nan (refactor this part if you get time in future)
        for i in range(len(array)-1, -1, -1):

            if not ma.isnan(array[i]):
                array = array[:i+1]
                break

        # return the array after passing the array to a diffrent function
        return self.get_lane_change_array(array)

    # function to get an array of the tick when a turn took place
    def get_lane_change_array(self, array):

        # empty array
        res = [0]
        curr = 0

        # print(array)

        array_int = []
        for i in array: 
            if ma.isnan(i): break
            array_int.append(int(i))

        for idx, val in enumerate(array):
            if curr != val:
                curr = val
                res.append(val)

        return res
    
    # function to generate a line plot for now
    def plot_line_plot(self, variable, title):
        
#         line_titles = self.get_titles(variable)
        line_titles = self.get_line_titles()
        
#         print(len(self.lane_data_temp))
        
        for idx, row in enumerate(self.lane_data_temp):
            
            self.turns = [i for i in range(len(row))]
            plt.plot(row, self.turns, label = str(line_titles[idx]))
        
        plt.xlim(left=0)
        plt.ylim(bottom=0)
        fs = 18
        plt.title(title, fontsize=fs+2)
        plt.xlabel("Distance Covered", fontsize=fs)
        plt.ylabel("No. of Lane Changes", fontsize=fs)
        plt.savefig(variable + ".png")
        plt.legend()
        plt.show()
        
        return plt
        
    # function to filter data for bar plot
    def filter_data_for_bar_plot(self, interval):
        
        values = []
        
        left = 0
        threshold = interval
        
        for row in self.lane_data_temp:
            
            temp = []
            threshold = interval
            
#             print(row)
            
            for i, val in enumerate(row):
                
                if val > threshold:
#                     print(row[i-1], row[left], i, left, threshold)
                    
                    if i - left - 1 != 0 and (row[i-1] > row[left]):
                        temp.append( (row[i-1] - row[left]) / (i - left - 1) )
                    else:
                        temp.append(0)
                        
                    left = i
                    threshold += interval
            
#             if left != len(row) - 1:
#                 temp.append( (row[i-1] - row[left]) / (i - left - 1) )
#             else:
#                 temp.append(0)
            
            values.append(temp)
        
        return values
        
        
        
    # function to plot a multiple bar plot for the decisions
    def plot_bar_plot(self, variable, title, interval):
        
        data = self.modify(self.filter_data_for_bar_plot(interval))
        decisions = self.get_line_titles()
        
        dicty = {}
        
        max_x_elements = max( [ len(row) for row in data ] )
        
        titles = [ str(i* interval)+" - "+str((i + 1) * interval) for i in range(max_x_elements) ]
        
        for idx, each_decision in enumerate(data):
            
            dicty[decisions[idx]] = each_decision
            
        plotdata = pd.DataFrame(dicty, index=titles)
        plotdata.plot(kind="bar")
 
        plotdata.head()
        fs = 18 # font size
        plt.title(title, fontsize=fs+2)
        plt.xlabel("Intervals", fontsize=fs)
        plt.ylabel("Moving Average", fontsize=fs)
        
        return plotdata
        
    # function to return the data for other purpose
    def get_data_for_analysis(self):
        return self.filter_data_for_bar_plot(500)
        
    # function to return the line titles for all the decisions
    def get_line_titles(self):
        return [i + 1 for i in range(self.no_of_decisions)]
        
    # function to get the variable values as titles
    def get_titles(self, target):
        
        res = []

        for _, values in self.characteristics.items():
            res.append(values[target])
        
        return res
    
    # function to return data that could be plotted using a moving average plot
    def get_data_for_moving_avg(self):
        
        values = []
        
        for row in self.lane_data_temp:
            temp_arr = [0 for _ in range(len(row)-1)] 
            for j in range(1, len(row)):
                temp_arr[j-1] =  row[j] - row[j-1] if row[j] > row[j-1] else 0
        
            values.append(temp_arr)
        
        return values
    
    # function to return a moving average plot
    def get_moving_average_plot(self, variable, title, interval):
        
        data = self.get_data_for_moving_avg()
        decisions = self.get_line_titles()
        
        dicty = {}
        
        max_x_elements = max( [ len(row) for row in data ] )
        
#         titles = [ str(i* interval)+" - "+str((i + 1) * interval) for i in range(max_x_elements) ]
        
        for idx, each_decision in enumerate(data):
            
            dicty[decisions[idx]] = each_decision
            
        plotdata = pd.DataFrame(dicty)
        
        for i in range(self.no_of_decisions):
            
            plotdata["0"+str(i+1)] = plotdata.iloc[:, i].rolling(window=interval).mean()
            
        for i in range(self.no_of_decisions):
            del plotdata[i+1]
 
        # it is a bit finicky but it works for now
        plotdata.plot(kind="line")
        
        
        fs = 18 # font size
        plt.title(title, fontsize=fs+2)
        plt.xlabel("No. of Lane Changes", fontsize=fs)
        plt.ylabel("Moving Avg", fontsize=fs)
        
        return plotdata
        
        
        
        
        
        
        
        
        
        
        
