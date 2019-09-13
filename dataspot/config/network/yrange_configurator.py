from dataspot.config.configurator import Configurator


class YRangeConfigurator(Configurator):
    """

    """

    def __init__(self, config):
        """
        :param config: The config parameter is a dictionary containing all of the Dataspot basic configurations. An
                       example of the basic structure can be found in examples/dataspot_config_example.json
        :type config: dict
        """
        self.__config = config
        self.__y_range = None

    def set_config(self, config):
        """
        :param config: The config parameter is a dictionary containing all of the Dataspot basic configurations. An
                       example of the basic structure can be found in examples/dataspot_config_example.json
        :type config: dict
        """
        self.__config = config

    def get_config(self):
        """
        :return: The config parameter is a dictionary containing all of the Dataspot basic configurations. An
                 example of the basic structure can be found in examples/dataspot_config_example.json
        :rtype: dict
        """
        return self.__config

    def set_y_range_config(self, config):
        """
        :param config: The config parameter is a dictionary containing all of the Dataspot basic configurations. An
                       example of the basic structure can be found in examples/dataspot_config_example.json
        :type config: dict
        """
        if not isinstance(config, dict):
            raise TypeError("The configuration that has been provided is not of a dictionary type")

        if not isinstance(config['network_config'], list):
            raise TypeError("The network configuration should be provided in a list")

        if not isinstance(config['network_config'][0], dict):
            raise TypeError("The plot width configuration is not of a dictionary type")

        if 'y_range' not in config['network_config'][3].keys():
            raise KeyError("The x-range configuration is not present in the correct location")

        # if not isinstance(config['network_config'][3]['y_range'], list):
        #     raise TypeError("The value of the plot with should be of an list type")
        #
        # for value in config['network_config'][3]['y_range']:
        #     if not isinstance(config['network_config'][3]['y_range'][value], int):
        #         raise TypeError("The value of the y-range extreme with should be of an integer type")

        y_range = config['network_config'][2]['y_range']
        self.__y_range = y_range

    def get_y_range_config(self):
        """
        :return:
        :rtype: list
        """
        return self.__y_range

    def build(self):
        """
        """
        config = self.get_config()
        self.set_y_range_config(config=config)
