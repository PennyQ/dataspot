from dataspot.visualization.visualizer import Visualizer
from dataspot.visualization.visual.helper.legend_helper import LegendHelper
from bokeh.models.widgets import Div


class LegendVisualizer(Visualizer):

    def __init__(self, network_builder):
        self.__grouped_colors = network_builder.get_grouped_colors()
        self.__grouped_legend = network_builder.get_grouped_legend()
        self.__layout = None
        self.__source = None

    def set_source(self):
        legend_names = LegendHelper.get_list(grouped_item=self.__grouped_legend)
        colors = LegendHelper.get_list(grouped_item=self.__grouped_colors)

        legend = LegendHelper.get_legend(colors=colors, legend_names=legend_names)

        self.__source = legend

    def get_source(self):
        return self.__source

    def set_layout(self):
        layout = Div(text=self.__source)
        self.__layout = layout

    def get_layout(self):
        return self.__layout

    def build(self):
        self.set_source()
        self.set_layout()
