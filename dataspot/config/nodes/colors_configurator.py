from dataspot.config.configurator import Configurator


class ColorsConfigurator(Configurator):
    """

    """

    def __init__(self, config):
        """
        :param config: The config parameter is a dictionary containing all of the Dataspot basic configurations. An
                       example of the basic structure can be found in examples/dataspot_config_example.json
        :type config: dict
        """
        self.__config = config
        self.__grouped_colors = None

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

    def set_grouped_colors_config(self, config):
        """
        :param config: The config parameter is a dictionary containing all of the Dataspot basic configurations. An
                       example of the basic structure can be found in examples/dataspot_config_example.json
        :type config: dict
        """
        if not isinstance(config, dict):
            raise TypeError("The configuration that has been provided is not of a dictionary type")
        if not isinstance(config['relationships_config'], dict):
            raise TypeError("The relationships configuration should be provided in a dictionary")
        if not isinstance(config['relationships_config']['groups'], dict):
            raise TypeError("The groups configuration should be provided in a dictionary")

        grouped_colors = dict()

        for group in config['relationships_config']['groups'].keys():
            if 'color' in config['relationships_config']['groups'][group]:
                grouped_colors[group] = config['relationships_config']['groups'][group]['color']

        grouped_colors['unknown'] = 'red'

        self.__grouped_colors = grouped_colors

    def get_grouped_colors_config(self):
        """
        :return:
        :rtype: dict
        """
        return self.__grouped_colors

    def build(self):
        """
        """
        config = self.get_config()
        self.set_grouped_colors_config(config=config)

# for group in config['relationships_config']['groups'].keys():
#     for configs in config['relationships_config']['groups'][group]:
#         for config_key, config_value in configs.items():
#             if config_key == 'color':
#                 grouped_colors[group] = config_value
