from dataspot.config.configurator import Configurator


class XRangeConfigurator(Configurator):

    def __init__(self):
        self.__x_range = None

    def set_config(self, config):
        x_range = None
        for config in config['network_config']:
            for config_key, config_value in config.items():
                if config_key == 'x_range':
                    x_range = (config_value[0], config_value[1])

        self.__x_range = x_range

    def get_config(self):
        return self.__x_range

    def build(self, config):
        self.set_config(config=config)

