from dataspot.visualization.visual.button_visualizer import ButtonVisualizer
from dataspot.visualization.visual.report_visualizer import ReportVisualizer
from dataspot.visualization.visual.legend_vizualizer import LegendVisualizer
from dataspot.network.builder.node_network_builder import NodeNetworkBuilder
from dataspot.network.builder.network_builder import NetworkBuilder
from bokeh.layouts import column, row


class VisualBuilder:

    def __init__(self, config, relationships):
        self.__config = config
        self.__relationships = relationships
        self.__network_builder = NetworkBuilder()
        self.__network_builder.build(config=self.__config, relationships=self.__relationships, force=0)
        self.__node_network_builder = NodeNetworkBuilder()
        self.__node_network_builder.set_relationships(relationships=relationships)
        self.__network = self.__network_builder.get_network()
        self.__buttons = None
        self.__legend = None
        self.__report = None
        self.__visual = None

    def set_legend(self):
        legend_visualizer = LegendVisualizer(network_builder=self.__network_builder)
        legend_visualizer.build()
        self.__legend = legend_visualizer.get_layout()

    def set_buttons(self):
        button_visualizer = ButtonVisualizer(button_config=self.__config["button_config"],
                                             network_builder=self.__network_builder,
                                             node_network_builder=self.__node_network_builder,
                                             relationships=self.__relationships)
        button_visualizer.build()
        self.__buttons = button_visualizer.get_layout()

    def set_report(self):
        report_visualizer = ReportVisualizer(network_builder=self.__network_builder)
        report_visualizer.build()
        self.__report = report_visualizer.get_layout()

    def set_visual(self):
        self.__buttons.height = 200
        self.__buttons.height_policy = 'fixed'

        side_bar = column(self.__buttons, self.__legend)
        network = column([self.__network], width=1050)
        layout = row(network, side_bar)

        layout = column(layout, self.__report)
        layout.margin = 40

        self.__visual = layout

    def get_visual(self):
        return self.__visual

    def build(self):
        self.set_legend()
        self.set_buttons()
        self.set_report()
        self.set_visual()
