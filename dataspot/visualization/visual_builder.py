from dataspot.visualization.visual.button_visualizer import ButtonVisualizer
from dataspot.visualization.visual.report_visualizer import ReportVisualizer
from dataspot.visualization.visual.legend_vizualizer import LegendVisualizer
from dataspot.network.builder.network_builder import NetworkBuilder
from bokeh.layouts import column, row


class VisualBuilder:

    def __init__(self, config, relationships):
        self.__config = config
        self.__relationships = relationships
        self.__network_builder = None
        self.__buttons = None
        self.__legend = None
        self.__report = None
        self.__visual = None

    def get_config(self):
        return self.__config

    def get_relationships(self):
        return self.__relationships

    def set_network_builder(self):
        config = self.get_config()
        relationships = self.get_relationships()
        network_builder = NetworkBuilder(config=config, relationships=relationships)
        network_builder.build()
        self.__network_builder = network_builder

    def get_network_builder(self):
        return self.__network_builder

    def set_legend(self):
        network_builder = self.get_network_builder()
        legend_visualizer = LegendVisualizer(network_builder=network_builder)
        legend_visualizer.build()
        self.__legend = legend_visualizer.get_layout()

    def get_legend(self):
        return self.__legend

    def set_buttons(self):
        network_builder = self.get_network_builder()
        button_visualizer = ButtonVisualizer(network_builder=network_builder)
        button_visualizer.build()
        self.__buttons = button_visualizer.get_layout()

    def get_buttons(self):
        return self.__buttons

    def set_report(self):
        network_builder = self.get_network_builder()
        report_visualizer = ReportVisualizer(network_builder=network_builder)
        report_visualizer.build()
        self.__report = report_visualizer.get_layout()

    def get_report(self):
        return self.__report

    def set_visual(self):
        buttons = self.get_buttons()
        buttons.height = 200
        buttons.height_policy = 'fixed'
        legend = self.get_legend()

        side_bar = column(buttons, legend)
        network_builder = self.get_network_builder()
        network = network_builder.get_network()
        network = column([network], width=1050)
        layout = row(network, side_bar)

        report = self.get_report()
        layout = column(layout, report)
        layout.margin = 40

        self.__buttons = buttons
        self.__visual = layout

    def get_visual(self):
        return self.__visual

    def build(self):
        self.set_network_builder()
        self.set_legend()
        self.set_buttons()
        self.set_report()
        self.set_visual()
