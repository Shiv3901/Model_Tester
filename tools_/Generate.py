from tools_ import Analyse

class Generate:
    
    def generate_plot(self, path, variable, title):
        
        self.analyse_obj = Analyse.Analyse(path)
        self.analyse_obj.plot_line_plot(variable, title)

    def get_data_from_Analyse(self):
        return self.analyse_obj.get_data_for_analysis()