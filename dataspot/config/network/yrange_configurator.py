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

        if not isinstance(config['network_config'], dict):
            raise TypeError("The network configuration should be provided in a dict")

        if 'y_range' not in config['network_config'].keys():
            raise KeyError("The y-range configuration has not been set.")

        if not isinstance(config['network_config']['y_range'], list):
            raise TypeError("The y-range configuration is not of a list type")

        y_range = config['network_config']['y_range']
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
