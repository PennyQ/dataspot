from dataspot.config.configurator import Configurator


class LegendConfigurator(Configurator):
    """

    """

    def __init__(self, config):
        self.__config = config
        self.__grouped_legend = None

    def set_config(self, config):
        self.__config = config

    def get_config(self):
        return self.__config

    def set_grouped_legend_config(self, config):
        grouped_legend = dict()

        # 1: Iterate over each group key
        # 2: Per group key, iterate over the config_old keys
        # 3: If the config_old key 'legend_name' is found, the color is appended to the grouped_legend_name dict for
        #    the respective group
        for group in config['relationships_config']['groups'].keys():
            for configs in config['relationships_config']['groups'][group]:
                for config_key, config_value in configs.items():
                    if config_key == 'legend_name':
                        grouped_legend[group] = config_value

        self.__grouped_legend = grouped_legend

    def get_grouped_legend_config(self):
        return self.__grouped_legend

    def build(self):
        config = self.get_config()
        self.set_grouped_legend_config(config=config)
