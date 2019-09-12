from dataspot.config.configurator import Configurator


class YRangeConfigurator(Configurator):
    """

    """

    def __init__(self, config):
        self.__config = config
        self.__y_range = None

    def set_config(self, config):
        self.__config = config

    def get_config(self):
        return self.__config

    def set_y_range_config(self, config):
        y_range = None
        for config in config['network_config']:
            for config_key, config_value in config.items():
                if config_key == 'y_range':
                    y_range = (config_value[0], config_value[1])

        self.__y_range = y_range

    def get_y_range_config(self):
        return self.__y_range

    def build(self):
        config = self.get_config()
        self.set_y_range_config(config=config)
