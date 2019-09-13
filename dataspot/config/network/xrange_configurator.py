from dataspot.config.configurator import Configurator


class XRangeConfigurator(Configurator):
    """

    """

    def __init__(self, config):
        """
        :param config: The config parameter is a dictionary containing all of the Dataspot basic configurations. An
                       example of the basic structure can be found in examples/dataspot_config_example.json
        :type config: dict
        """
        self.__config = config
        self.__x_range = None

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

    def set_x_range_config(self, config):
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

        if 'x_range' not in config['network_config'][2].keys():
            raise KeyError("The x-range configuration is not present in the correct location")

        # if not isinstance(config['network_config'][2]['x_range'], list):
        #     raise TypeError("The value of the plot with should be of an list type")
        #
        # for value in config['network_config'][2]['x_range']:
        #     if not isinstance(config['network_config'][2]['x_range'][value], int):
        #         raise TypeError("The value of the x-range extreme with should be of an integer type")

        x_range = config['network_config'][2]['x_range']

        self.__x_range = x_range

    def get_x_range_config(self):
        """
        :return:
        :rtype: list
        """
        return self.__x_range

    def build(self):
        """
        """
        config = self.get_config()
        self.set_x_range_config(config=config)

