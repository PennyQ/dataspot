from dataspot.config.configurator import Configurator
from dataspot.config.nodes.colors_configurator import ColorsConfigurator
from dataspot.config.nodes.legend_configurator import LegendConfigurator
from dataspot.config.nodes.weights_configurator import WeightsConfigurator
from dataspot.config.nodes.nodes_configurator import NodesConfigurator


class NodesConfiguratorBuilder(Configurator):
    """

    """

    def __init__(self, config, relationships):
        self.__config = config
        self.__relationships = relationships
        self.__grouped_nodes = None
        self.__grouped_colors = None
        self.__grouped_legend = None
        self.__grouped_weights = None

    def set_config(self, config):
        self.__config = config

    def get_config(self):
        return self.__config

    def set_relationships(self, relationships):
        self.__relationships = relationships

    def get_relationships(self):
        return self.__relationships

    def set_grouped_nodes(self, config, relationships):
        nodes_configurator = NodesConfigurator(config=config, relationships=relationships)
        nodes_configurator.build()
        self.__grouped_nodes = nodes_configurator.get_config()

    def get_grouped_nodes(self):
        return self.__grouped_nodes

    def set_grouped_colors(self, config):
        node_colors_configurator = ColorsConfigurator(config=config)
        node_colors_configurator.build()
        self.__grouped_colors = node_colors_configurator.get_config()

    def get_grouped_colors(self):
        return self.__grouped_colors

    def set_grouped_legend(self, config):
        node_legend_configurator = LegendConfigurator(config=config)
        node_legend_configurator.build()
        self.__grouped_legend = node_legend_configurator.get_config()

    def get_grouped_legend(self):
        return self.__grouped_legend

    def set_grouped_weights(self, config, grouped_nodes):
        node_weights_configurator = WeightsConfigurator(config=config, grouped_nodes=grouped_nodes)
        node_weights_configurator.build()
        self.__grouped_weights = node_weights_configurator.get_config()

    def get_grouped_weights(self):
        return self.__grouped_weights

    def build(self):
        config = self.get_config()
        relationships = self.get_relationships()

        self.set_grouped_nodes(config=config, relationships=relationships)
        self.set_grouped_colors(config=config)
        self.set_grouped_legend(config=config)

        grouped_nodes = self.__grouped_nodes
        self.set_grouped_weights(config=config, grouped_nodes=grouped_nodes)
