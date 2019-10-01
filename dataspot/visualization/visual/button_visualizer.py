from dataspot.visualization.visual.button_builder import ButtonBuilder
from bokeh.layouts import column


class ButtonVisualizer:

    def __init__(self, network_builder):
        self.__network_builder = network_builder
        self.__layout = None
        self.__buttons = None

    def get_network_builder(self):
        return self.__network_builder

    def set_buttons(self):
        network_builder = self.get_network_builder()
        button_builder = ButtonBuilder(network_builder=network_builder)
        button_builder.build()
        buttons = button_builder.get_buttons()
        self.__buttons = buttons

    def get_buttons(self):
        return self.__buttons

    def set_layout(self):
        buttons = self.get_buttons()
        layout = column(buttons)
        self.__layout = layout

    def get_layout(self):
        return self.__layout

    def build(self):
        self.set_buttons()
        self.set_layout()
