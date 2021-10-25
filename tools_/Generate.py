from tools_ import Analyse

class Generate:
    
    # constructor to create individual objects for all the datasets
    def __init__(self, direc: str,paths, number_of_decisions):
        self.analyse_obj_array = [ Analyse.Analyse(direc + "/" + path, number_of_decisions) for path in paths ]
        
    # function to call all other functions to plot various plots
    def generate_all_plots(self, variable, title, width, interval, titles):
        self.generate_line_plot(variable, title)
        self.generate_bar_plot(variable, title, width)
        self.generate_moving_avg_plot(variable, title, interval, titles)
    
    # call method of Analyse class to plot a line plot for all the datasets
    def generate_line_plot(self, variable, title):
         
        for obj in self.analyse_obj_array:
            obj.plot_line_plot(variable, title)
            
        return
        
    # call method of Analyse class to plot a bar plot for all the datasets
    def generate_bar_plot(self, variable, title, width):
    
        for obj in self.analyse_obj_array:
            obj.plot_bar_plot(variable, title, width)
            
        return
        

    # call method of Analyse class to plot a moving average plot for all the datasets
    def generate_moving_avg_plot(self, variable, title, interval, titles):
    
        for idx, obj in enumerate(self.analyse_obj_array):
            obj.get_moving_average_plot(variable, "Run " + str(idx+1) + ": " + title, interval, titles)
            
        return
    
    # temporary function for debugging the data received from analyse objs (PLEASE REMOVE THIS IF NOT NEEDED)
    def get_data_from_Analyse(self):
    
        for obj in self.analyse_obj_array:
            obj.get_data_for_analysis()
            
        return
    
    
    
