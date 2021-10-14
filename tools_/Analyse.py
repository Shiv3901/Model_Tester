import pandas as pd
from matplotlib import pyplot as plt
from plotly import graph_objs as go
from plotly.offline import init_notebook_mode, iplot
init_notebook_mode(connected=True)
import math as ma

class Analyse:
    
    def __init__(self, path):

        # read in the data
        self.data = pd.read_csv(path, low_memory=False)
        
        # get the number of columns which are the number of runs done for analysis
        self.cols = self.data.shape[1] - 1
        
        # get a dictionary of all the characteristics avaiables (basically they are all variables)
        self.characteristics = self.get_characteristics()
        
        # get the formatted version that could be used to plot the data
        self.lane_data_temp = self.get_all_lanes_data()
        
        # array for the number of turns (right now the only variable for testing)
        self.turns = []
    
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
            temp_arr = self.get_array(self.data[str(col+1)][11:])
            values.append(temp_arr)
        
        return values
    
    # function to average out the runs from the data
    def filter_all_data(self):
        
        size_of_runs = len(self.lane_data_temp) // 4
        
        values = self.lane_data_temp
        new_values = []
        
        for i in range(4, size_of_runs):
            
            temp_arr = [0] * len(values[i])
            
            for j in range(size_of_runs):
                
                for k, val in enumerate(values[i+j]):
                    
                    print("adgf")
                    
        return 
                
                
            
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
        
        array_int = []
        for i in array: array_int.append(int(i))
        
        for idx, val in enumerate(array):
            if curr != val:
                curr = val
                res.append(val)
        
        return res
    
    # function to generate a line plot for now
    def plot_line_plot(self, variable, title):
        
        titles = self.get_titles(variable)
        
        for idx, column in enumerate(self.lane_data_temp):
            
            self.turns = [i for i in range(len(column))]
            plt.plot(column, self.turns, label = str(titles[idx]))
        
        plt.xlim(left=0)
        plt.ylim(bottom=0)
        plt.xlabel(title, fontsize=28)
        plt.ylabel("No. of Lane Changes", fontsize=28)
        plt.savefig(variable + ".png")
        plt.legend()
        plt.show()
        
    # function to return the data for other purpose
    def get_data_for_analysis(self):
        return self.lane_data_temp
        
    # function to get the variable values as titles
    def get_titles(self, target):
        
        res = []
        
        for _, values in self.characteristics.items():
            res.append(values[target])
        
        return res
