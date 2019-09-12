from dataspot.config.configurator import Configurator


class ColorsConfigurator(Configurator):
    """

    """

    def __init__(self, config):
        self.__config = config
        self.__grouped_colors = None

    def set_config(self, config):
        self.__config = config

    def get_config(self):
        return self.__config

    def set_grouped_colors_config(self, config):
        grouped_colors = dict()

        for group in config['relationships_config']['groups'].keys():
            for configs in config['relationships_config']['groups'][group]:
                for config_key, config_value in configs.items():
                    if config_key == 'color':
                        grouped_colors[group] = config_value

        self.__grouped_colors = grouped_colors

    def get_grouped_colors_config(self):
        return self.__grouped_colors

    def build(self):
        config = self.get_config()
        self.set_grouped_colors_config(config=config)
