from dataspot.config.configurator import Configurator


class GoldenSourcesConfigurator(Configurator):
    """
    A Golden Source object is an object (aka node) that is (one of) the root(s) of the network analysis. This object
    could also resemble an important starting point from which the analyzer would conduct its analysis.

    """

    def __init__(self, config):
        """
        :param config: The config parameter is a dictionary containing all of the Dataspot basic configurations. An
                       example of the basic structure can be found in examples/dataspot_config_example.json
        :type config: dict
        """
        self.__config = config
        self.__golden_sources_config = None

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

    def set_golden_sources_config(self, config):
        """
        :param config: The config parameter is a dictionary containing all of the Dataspot basic configurations. An
                       example of the basic structure can be found in examples/dataspot_config_example.json
        :type config: dict
        """
        if not isinstance(config, dict):
            raise TypeError("The configuration that has been provided is not of a dictionary type")

        if not isinstance(config['network_config'], dict):
            raise TypeError("The network configuration should be provided in a dict")

        if 'golden_sources' not in config['network_config'].keys():
            raise KeyError("The golden_sources configuration has not been set.")

        if not isinstance(config['network_config']['golden_sources'], list):
            raise TypeError("The golden sources configuration is not of a list type")

        golden_sources_config = config['network_config']['golden_sources']
        self.__golden_sources_config = golden_sources_config

    def get_golden_sources_config(self):
        """
        :return: A list containing all of the golden sources of the network graph.
        :rtype: list
        """
        return self.__golden_sources_config

    def build(self):
        """
        The build function prepares all of the golden source configuration components at once.

        """
        config = self.get_config()
        self.set_golden_sources_config(config=config)
