from dataspot.visualization.visualizer import Visualizer
from dataspot.visualization.visual.button_builder import ButtonBuilder
from bokeh.layouts import column


class ButtonVisualizer(Visualizer):

    def __init__(self, button_config, network_builder, node_network_builder, relationships):
        self.__button_config = button_config
        self.__network_builder = network_builder
        self.__node_network_builder = node_network_builder
        self.__relationships = relationships
        self.__layout = None
        self.__source = None

    def set_source(self):
        button_builder = ButtonBuilder(button_config=self.__button_config,
                                       network_builder=self.__network_builder,
                                       node_network_builder=self.__node_network_builder,
                                       relationships=self.__relationships)
        button_builder.build()
        source = button_builder.get_buttons()
        self.__source = source

    def get_source(self):
        return self.__source

    def set_layout(self):
        layout = column(self.__source)
        self.__layout = layout

    def get_layout(self):
        return self.__layout

    def build(self):
        self.set_source()
        self.set_layout()
