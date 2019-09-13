from dataspot.config.configurator import Configurator
from dataspot.config.nodes.colors_configurator import ColorsConfigurator
from dataspot.config.nodes.legend_configurator import LegendConfigurator
from dataspot.config.nodes.weights_configurator import WeightsConfigurator
from dataspot.config.nodes.nodes_configurator import NodesConfigurator


class NodesConfiguratorBuilder(Configurator):
    """
    The NodesConfiguratorBuilder sets the basic characteristics of a node. The following characteristics of a node will
    be determined in this class:

    [*] To which group it belongs (grouped_nodes)
    [*] Which color the node should take (grouped_colors)
    [*] Which legend name is connected to it (grouped_legend)
    [*] What the weight of the node is (grouped_weights)
    """

    def __init__(self, config, relationships):
        """
        :param config: The config parameter is a dictionary containing all of the Dataspot basic configurations. An
                       example of the basic structure can be found in examples/dataspot_config_example.json
        :type config: dict
        :param relationships: A relationships dictionary, which has one object (aka node) as its keys, with each key
                             having a list of source objects (aka nodes) put together in a list object as its values.
        :type relationships: dict
        """
        if not isinstance(config, dict):
            raise TypeError("The configuration that has been provided is not of a dictionary type")

        if not isinstance(relationships, dict):
            raise TypeError("The relationships that have been provided are not of a dictionary type")

        self.__config = config
        self.__relationships = relationships
        self.__grouped_nodes = None
        self.__grouped_colors = None
        self.__grouped_legend = None
        self.__grouped_weights = None

    def set_config(self, config):
        """
        :param config: The config parameter is a dictionary containing all of the Dataspot basic configurations. An
                       example of the basic structure can be found in examples/dataspot_config_example.json
        :type config: dict
        """
        if not isinstance(config, dict):
            raise TypeError("The configuration that has been provided is not of a dictionary type")

        self.__config = config

    def get_config(self):
        """
        :return: The Dataspot config is a dictionary containing all of the Dataspot basic configurations. An
                 example of the basic structure can be found in examples/dataspot_config_example.json
        :rtype: dict
        """
        return self.__config

    def set_relationships(self, relationships):
        """
        :param relationships: A relationships dictionary, which has one object (aka node) as its keys, with each key
                             having a list of source objects (aka nodes) put together in a list object as its values.
        :type relationships: dict
        """
        if not isinstance(relationships, dict):
            raise TypeError("The relationships that have been provided are not of a dictionary type")

        self.__relationships = relationships

    def get_relationships(self):
        """
        :return: A relationships dictionary, which has one object (aka node) as its keys, with
                 each key having a list of source objects (aka nodes) put together in a list object as its
                 values.
        :rtype: dict
        """
        return self.__relationships

    def set_grouped_nodes(self, config, relationships):
        """
        A grouped nodes object consists of nodes, which are grouped together based either on the 'nodes' arguments of
        any of the arguments provided in the 'args' key.

        :param config: The config parameter is a dictionary containing all of the Dataspot basic configurations. An
                       example of the basic structure can be found in examples/dataspot_config_example.json
        :type config: dict
        :param relationships: A relationships dictionary, which has one object (aka node) as its keys, with each key
                             having a list of source objects (aka nodes) put together in a list object as its values.
        :type relationships: dict
        """
        if not isinstance(config, dict):
            raise TypeError("The configuration that has been provided is not of a dictionary type")

        if not isinstance(relationships, dict):
            raise TypeError("The relationships that have been provided are not of a dictionary type")

        nodes_configurator = NodesConfigurator(config=config, relationships=relationships)
        nodes_configurator.build()
        grouped_nodes = nodes_configurator.get_grouped_nodes_config()
        self.__grouped_nodes = grouped_nodes

    def get_grouped_nodes(self):
        """
        :return: Nodes (aka objects) are grouped together based either on the 'nodes' arguments of any of the arguments
                 provided in the 'args' key.
        :rtype: dict
        """
        return self.__grouped_nodes

    def set_grouped_colors(self, config):
        """
        A grouped colors object consists of nodes, which are grouped together based on the colors they should get in
        the visualization, based on the configuration provided in the Dataspot config file.

        :param config: The config parameter is a dictionary containing all of the Dataspot basic configurations. An
                       example of the basic structure can be found in examples/dataspot_config_example.json
        :type config: dict
        """
        if not isinstance(config, dict):
            raise TypeError("The configuration that has been provided is not of a dictionary type")

        node_colors_configurator = ColorsConfigurator(config=config)
        node_colors_configurator.build()
        grouped_colors = node_colors_configurator.get_grouped_colors_config()
        self.__grouped_colors = grouped_colors

    def get_grouped_colors(self):
        """
        :return: Nodes (aka objects) are grouped together based on the colors they should get in the visualization,
                 based on the configuration provided in the Dataspot config file.
        :rtype: dict
        """
        return self.__grouped_colors

    def set_grouped_legend(self, config):
        """
        A grouped legend object consists of nodes, which are grouped together based on the legend name it should represent, which in
        turn was assigned by the config file.

        :param config: The config parameter is a dictionary containing all of the Dataspot basic configurations. An
                       example of the basic structure can be found in examples/dataspot_config_example.json
        :type config: dict
        """
        if not isinstance(config, dict):
            raise TypeError("The configuration that has been provided is not of a dictionary type")

        node_legend_configurator = LegendConfigurator(config=config)
        node_legend_configurator.build()
        grouped_legend = node_legend_configurator.get_grouped_legend_config()
        self.__grouped_legend = grouped_legend

    def get_grouped_legend(self):
        """
        :return: A dictionary containing nodes (aka objects), which are grouped together based on the legend name it
                should represent.
        :rtype: dict
        """
        return self.__grouped_legend

    def set_grouped_weights(self, config, grouped_nodes):
        """
        A grouped weights consists of nodes, which are grouped together based on their weight that was assigned by the config
        file.

        :param config: The config parameter is a dictionary containing all of the Dataspot basic configurations. An
                       example of the basic structure can be found in examples/dataspot_config_example.json
        :type config: dict
        :param grouped_nodes:
        :return:
        """
        if not isinstance(config, dict):
            raise TypeError("The configuration that has been provided is not of a dictionary type")

        if not isinstance(grouped_nodes, dict):
            raise TypeError("The grouped nodes that have been provided are not of a dictionary type")

        node_weights_configurator = WeightsConfigurator(config=config, grouped_nodes=grouped_nodes)
        node_weights_configurator.build()
        grouped_weights = node_weights_configurator.get_grouped_weights_config()
        self.__grouped_weights = grouped_weights

    def get_grouped_weights(self):
        """
        :return: A dictionary containing nodes (aka objects), which are grouped together based on their weight that was
                 assigned by the config file.
        :rtype: dict
        """
        return self.__grouped_weights

    def build(self):
        """
        The build function prepares all of the node configuration components at once.
        """
        config = self.get_config()
        relationships = self.get_relationships()

        self.set_grouped_nodes(config=config, relationships=relationships)
        self.set_grouped_colors(config=config)
        self.set_grouped_legend(config=config)

        grouped_nodes = self.__grouped_nodes
        self.set_grouped_weights(config=config, grouped_nodes=grouped_nodes)
