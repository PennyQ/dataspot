from dataspot.config.configurator import Configurator


class XRangeConfigurator(Configurator):

    def __init__(self, config):
        self.__config = config
        self.__x_range = None

    def set_config(self, config):
        self.__config = config

    def get_config(self):
        return self.__config

    def set_x_range_config(self, config):
        x_range = None
        for config in config['network_config']:
            for config_key, config_value in config.items():
                if config_key == 'x_range':
                    x_range = (config_value[0], config_value[1])

        self.__x_range = x_range

    def get_x_range_config(self):
        return self.__x_range

    def build(self):
        config = self.get_config()
        self.set_x_range_config(config=config)

