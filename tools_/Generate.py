from tools_ import Analyse

class Generate:
    
    def __init__(self, paths):
        self.analyse_obj_array = [ Analyse.Analyse(path) for path in paths ]
    
    def generate_line_plot(self, variable, title):
         
        for obj in self.analyse_obj_array:
            obj.plot_line_plot(variable, title)
            
        return
        
    def generate_bar_plot(self, variable, title, interval):
    
        for obj in self.analyse_obj_array:
            obj.plot_bar_plot(variable, title, interval)
            
        return
        

    def generate_moving_avg_plot(self, variable, title, interval):
    
        for idx, obj in enumerate(self.analyse_obj_array):
            obj.get_moving_average_plot(variable, "Run " + str(idx+1) + ": " + title, interval)
            
        return
    
    def get_data_from_Analyse(self):
    
        for obj in self.analyse_obj_array:
            obj.get_data_for_analysis()
            
        return
    
    
    