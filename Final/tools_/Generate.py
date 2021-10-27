from tools_ import Analyse

''' Class Generate config details

==> List of all available functions (COULD BE MADE PRIVATE AS PER USER's WISH)

- __init__(direc, paths, number_of_decisions, titles)
- generate_all_plots(title_for_plot, width, interval)
- generate_line_plot(self, title_for_plot)
- generate_bar_plot(title_for_plot, width)
- generate_moving_avg_plot(title_for_plot, interval)

'''

# takes in an array of data_set paths and generate all sorts of visualisation
class Generate:

# START OF __init__ FUNCTION    

    # constructor to create individual Analyse objects for all the datasets
    def __init__(self, config_info):
        
        # get all the values using the keys (this way the constructor looks much better)
        
        direc = config_info["direc"] 
        paths = config_info["paths"] 
        no_of_decisions = config_info["no_of_decisions"] 
        labels_of_decisions = config_info["labels_of_decisions"] 
        prefix = config_info["prefix"] 
        blurb = config_info["blurb"] 
        suffix_main_titles = config_info["suffix_main_titles"] 
        
        # initialising an objects array that can be used in future to plot data
        self.analyse_obj_array = [ Analyse.Analyse(direc+ "/" + path, no_of_decisions, labels_of_decisions) for path in paths ]
        
        # generate main titles for all the graphs
        self.main_titles = [prefix + str(idx + 1) + blurb + title for idx, title in enumerate(suffix_main_titles)]

#-----------------------------------------------------------------------------------------------------------#

# START OF generate_all_plots FUNCTION
        
    # function to generate all the plots (basically calls every other functions avaiable)
    def generate_all_plots(self, width, interval):
        self.generate_line_plot()
        self.generate_bar_plot(width)
        self.generate_moving_avg_plot(interval)
        
        return

#-----------------------------------------------------------------------------------------------------------#

# START OF generate_line_plot FUNCTION
    
    # function to generate all the line plots 
    def generate_line_plot(self):
         
        # traverse through the array and call the corresponding functions
        for idx, obj in enumerate(self.analyse_obj_array):
            obj.get_line_plot(self.main_titles[idx])
        
        return 
        
#-----------------------------------------------------------------------------------------------------------#

# START OF generate_bar_plot FUNCTION

    # function to generate all the bar plots
    def generate_bar_plot(self, width):

        # traverse through the array and call the corresponding functions        
        for idx, obj in enumerate(self.analyse_obj_array):
            obj.get_bar_plot(self.main_titles[idx], width)
            
        return

#-----------------------------------------------------------------------------------------------------------#

# START OF generate_moving_avg_plot FUNCTION

    # function to generate all the moving avg plots
    def generate_moving_avg_plot(self, interval):
    
        # traverse through the array and call the corresponding functions    
        for idx, obj in enumerate(self.analyse_obj_array):
            obj.get_moving_average_plot(self.main_titles[idx], interval)
            
        return
    
#-----------------------------------------------------------------------------------------------------------#
