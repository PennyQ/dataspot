from dataspot.config.configurator import Configurator
from dataspot.config.network.plot_height_configurator import PlotHeightConfigurator
from dataspot.config.network.plot_width_configurator import PlotWidthConfigurator
from dataspot.config.network.xrange_configurator import XRangeConfigurator
from dataspot.config.network.yrange_configurator import YRangeConfigurator
from dataspot.config.network.node_size_configurator import NodeSizeConfigurator
from dataspot.config.network.golden_sources_configurator import GoldenSourcesConfigurator


class NetworkConfiguratorBuilder(Configurator):
    """
    The NetworkConfiguratorBuilder builds all of the items needed to set the basic conditions of the network.
    The following variables will be set:

    [*] Plot width
    [*] Plot height
    [*] X-range
    [*] Y-range
    [*] Node-size-config (Interval based configuration setting the possible sizes a node can take, score-based)
    [*] Golden Sources (Golden Sources are the absolute root of your network analysis. These objects are often the main
        starting points of your analysis.)
    """

    def __init__(self, config):
        """
        :param config: The config parameter is a dictionary containing all of the Dataspot basic configurations. An
                       example of the basic structure can be found in examples/dataspot_config_example.json
        :type config: dict
        """
        if not isinstance(config, dict):
            raise TypeError("The configuration that has been provided is not of a dictionary type")

        self.__config = config
        self.__plot_width = None
        self.__plot_height = None
        self.__x_range = None
        self.__y_range = None
        self.__node_size_config = None
        self.__golden_sources = None

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

    def set_plot_width(self, config):
        """
        :param config: The config parameter is a dictionary containing all of the Dataspot basic configurations. An
                       example of the basic structure can be found in examples/dataspot_config_example.json
        :type config: dict
        """
        if not isinstance(config, dict):
            raise TypeError("The configuration that has been provided is not of a dictionary type")

        plot_width_configurator = PlotWidthConfigurator(config=config)
        plot_width_configurator.build()
        plot_width = plot_width_configurator.get_plot_width_config()
        self.__plot_width = plot_width

    def get_plot_width(self):
        """
        :return: Returns the integer value for the width of the plot the network analysis will be placed in.
        :rtype: int
        """
        return self.__plot_width

    def set_plot_height(self, config):
        """
        :param config: The config parameter is a dictionary containing all of the Dataspot basic configurations. An
                       example of the basic structure can be found in examples/dataspot_config_example.json
        :type config: dict
        """
        if not isinstance(config, dict):
            raise TypeError("The configuration that has been provided is not of a dictionary type")

        plot_height_configurator = PlotHeightConfigurator(config=config)
        plot_height_configurator.build()
        plot_height = plot_height_configurator.get_plot_height_config()
        self.__plot_height = plot_height

    def get_plot_height(self):
        """
        :return: Returns the integer value for the height of the plot the network analysis will be placed in.
        :rtype: int
        """
        return self.__plot_height

    def set_x_range(self, config):
        """
        :param config: The config parameter is a dictionary containing all of the Dataspot basic configurations. An
                       example of the basic structure can be found in examples/dataspot_config_example.json
        :type config: dict
        """
        if not isinstance(config, dict):
            raise TypeError("The configuration that has been provided is not of a dictionary type")

        x_range_configurator = XRangeConfigurator(config=config)
        x_range_configurator.build()
        x_range = x_range_configurator.get_x_range_config()
        self.__x_range = x_range

    def get_x_range(self):
        """
        :return: Returns a list containing the two extremes (int) for the x-axis for the network graph.
        :rtype: list
        """
        return self.__x_range

    def set_y_range(self, config):
        """
        :param config: The config parameter is a dictionary containing all of the Dataspot basic configurations. An
                       example of the basic structure can be found in examples/dataspot_config_example.json
        :type config: dict
        """
        if not isinstance(config, dict):
            raise TypeError("The configuration that has been provided is not of a dictionary type")

        y_range_configurator = YRangeConfigurator(config=config)
        y_range_configurator.build()
        y_range = y_range_configurator.get_y_range_config()
        self.__y_range = y_range

    def get_y_range(self):
        """
        :return: Returns a list containing the two extremes (int) for the y-axis for the network graph.
        :rtype: list
        """
        return self.__y_range

    def set_node_size_config(self, config):
        """
        :param config: The config parameter is a dictionary containing all of the Dataspot basic configurations. An
                       example of the basic structure can be found in examples/dataspot_config_example.json
        :type config: dict
        """
        if not isinstance(config, dict):
            raise TypeError("The configuration that has been provided is not of a dictionary type")

        node_size_configurator = NodeSizeConfigurator(config=config)
        node_size_configurator.build()
        node_size_config = node_size_configurator.get_node_size_config()
        self.__node_size_config = node_size_config

    def get_node_size_config(self):
        """
        :return: A dictionairy containing an interval-based configuration, on which the node sizes are determined.
                 Dataspot takes the calculated root score and matches this with one of the interval levels in this
                 configuration.
        :rtype: dict
        """
        return self.__node_size_config

    def set_golden_sources(self, config):
        """
        :param config: The config parameter is a dictionary containing all of the Dataspot basic configurations. An
                       example of the basic structure can be found in examples/dataspot_config_example.json
        :type config: dict
        """
        if not isinstance(config, dict):
            raise TypeError("The configuration that has been provided is not of a dictionary type")

        golden_sources_configurator = GoldenSourcesConfigurator(config=config)
        golden_sources_configurator.build()
        golden_sources = golden_sources_configurator.get_golden_sources_config()
        self.__golden_sources = golden_sources

    def get_golden_sources(self):
        """
        :return: A list containing all of the golden sources of the network graph.
        :rtype: list
        """
        return self.__golden_sources

    def build(self):
        """
        The build function prepares all of the network configuration components at once.
        """
        config = self.get_config()
        self.set_plot_width(config=config)
        self.set_plot_height(config=config)
        self.set_x_range(config=config)
        self.set_y_range(config=config)
        self.set_node_size_config(config=config)
        self.set_golden_sources(config=config)

