import pandas as pd


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
            
            key_data = self.data["[run number]"][:5]
            temp_data = self.data[str(col+1)][:5]
            
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
            temp_arr = self.get_array(self.data[str(col+1)][10:])
            values.append(temp_arr)
        
        return values
    
    # function to get a single array in the required version
    def get_array(self, data):
        
        # empty array which is to be returned
        array = []
        
        for val in data: 
            array.append(val)
            
        # get all the values that are not nan (refactor this part if you get time in future)
        for i in range(len(array)-1, -1, -1):
            
            if not math.isnan(array[i]):
                array = array[:i+1]
                break
        
        # return the array after passing the array to a diffrent function
        return self.get_lane_change_array(array)
        
    # function to get an array of the tick when a turn took place
    def get_lane_change_array(self, array):
        
        # empty array
        res = [0]
        curr = 0
        
        for idx, val in enumerate(array):
            if curr != val:
                curr = val
                res.append(idx)
        
        return res
    
    # function to generate a line plot for now
    def plot_line_plot(self, variable):
        
        titles = self.get_titles(variable)
        
        for idx, column in enumerate(self.lane_data_temp):
            
            self.turns = [i for i in range(len(column))]
            plt.plot(column, self.turns, label = str(titles[idx]))
            
        plt.legend()
        plt.show()
        
    # function to get the variable values as titles
    def get_titles(self, target):
        
        res = []
        
        for _, values in self.characteristics.items():
            res.append(values[target])
        
        return res
