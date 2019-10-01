from dataspot.config.configurator import Configurator


class LegendConfigurator(Configurator):
    """

    """

    def __init__(self, config):
        """
        :param config: The config parameter is a dictionary containing all of the Dataspot basic configurations. An
                       example of the basic structure can be found in examples/dataspot_config_example.json
        :type config: dict
        """
        self.__config = config
        self.__grouped_legend = None

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

    def set_grouped_legend_config(self, config):
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

        grouped_legend = dict()

        for group in config['relationships_config']['groups'].keys():
            if 'legend_name' in config['relationships_config']['groups'][group]:
                grouped_legend[group] = config['relationships_config']['groups'][group]['legend_name']

        grouped_legend['unknown'] = 'unknown'

        self.__grouped_legend = grouped_legend

    def get_grouped_legend_config(self):
        return self.__grouped_legend

    def build(self):
        config = self.get_config()
        self.set_grouped_legend_config(config=config)

# # 1: Iterate over each group key
# # 2: Per group key, iterate over the config_old keys
# # 3: If the config_old key 'legend_name' is found, the color is appended to the grouped_legend_name dict for
# #    the respective group
# for group in config['relationships_config']['groups'].keys():
#     for configs in config['relationships_config']['groups'][group]:
#         for config_key, config_value in configs.items():
#             if config_key == 'legend_name':
#                 grouped_legend[group] = config_value