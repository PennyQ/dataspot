from dataspot.config.nodes.colors_configurator import ColorsConfigurator
from dataspot.config.nodes.legend_configurator import LegendConfigurator
from dataspot.config.nodes.weights_configurator import WeightsConfigurator
from dataspot.config.nodes.nodes_configurator import NodesConfigurator


class NodesConfiguratorBuilder:

    def __init__(self):
        self.__grouped_nodes = None
        self.__grouped_colors = None
        self.__grouped_legend = None
        self.__grouped_weights = None

    def set_grouped_nodes(self, config, relationships):
        nodes_configurator = NodesConfigurator()
        nodes_configurator.build(config=config, relationships=relationships)
        self.__grouped_nodes = nodes_configurator.get_config()

    def get_grouped_nodes(self):
        return self.__grouped_nodes

    def set_grouped_colors(self, config):
        node_colors_configurator = ColorsConfigurator()
        node_colors_configurator.build(config=config)
        self.__grouped_colors = node_colors_configurator.get_config()

    def get_grouped_colors(self):
        return self.__grouped_colors

    def set_grouped_legend(self, config):
        node_legend_configurator = LegendConfigurator()
        node_legend_configurator.build(config=config)
        self.__grouped_legend = node_legend_configurator.get_config()

    def get_grouped_legend(self):
        return self.__grouped_legend

    def set_grouped_weights(self, config, grouped_nodes):
        node_weights_configurator = WeightsConfigurator()
        node_weights_configurator.build(config=config, grouped_nodes=grouped_nodes)
        self.__grouped_weights = node_weights_configurator.get_config()

    def get_grouped_weights(self):
        return self.__grouped_weights

    def build(self, config, relationships):
        self.set_grouped_nodes(config=config, relationships=relationships)
        self.set_grouped_colors(config=config)
        self.set_grouped_legend(config=config)

        grouped_nodes = self.__grouped_nodes
        self.set_grouped_weights(config=config, grouped_nodes=grouped_nodes)
