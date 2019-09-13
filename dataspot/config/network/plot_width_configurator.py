from dataspot.config.configurator import Configurator


class PlotWidthConfigurator(Configurator):
    """

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
        :return: The config parameter is a dictionary containing all of the Dataspot basic configurations. An
                 example of the basic structure can be found in examples/dataspot_config_example.json
        :rtype: dict
        """
        return self.__config

    def set_plot_width_config(self, config):
        if not isinstance(config, dict):
            raise TypeError("The configuration that has been provided is not of a dictionary type")

        if not isinstance(config['network_config'], list):
            raise TypeError("The network configuration should be provided in a list")

        if not isinstance(config['network_config'][0], dict):
            raise TypeError("The plot width configuration is not of a dictionary type")
        
        if 'plot_width' not in config['network_config'][0].keys():
            raise KeyError("The plot width configuration is not present in the correct location")
        
        # if not isinstance(config['network_config'][0]['plot_width'], int):
        #     raise TypeError("The value of the plot with should be of an integer type")

        plot_width = config['network_config'][0]['plot_width']

        self.__plot_width = plot_width

    def get_plot_width_config(self):
        """
        :return:
        :rtype: int
        """
        return self.__plot_width

    def build(self):
        """
        """
        config = self.get_config()
        self.set_plot_width_config(config=config)
