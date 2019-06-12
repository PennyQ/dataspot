from dataspot.config.configurator import Configurator


class ColorsConfigurator(Configurator):

    def __init__(self):
        self.__grouped_colors = None

    def set_config(self, config):
        grouped_colors = dict()

        for group in config['relationships_config']['groups'].keys():
            for configs in config['relationships_config']['groups'][group]:
                for config_key, config_value in configs.items():
                    if config_key == 'color':
                        grouped_colors[group] = config_value

        self.__grouped_colors = grouped_colors

    def get_config(self):
        return self.__grouped_colors

    def build(self, config):
        self.set_config(config=config)
