from dataspot.config.configurator import Configurator


class GoldenSourcesConfigurator(Configurator):

    def __init__(self):
        self.__golden_sources_config = None

    def set_config(self, config):
        golden_sources_config = None
        for config in config['network_config']:
            for config_key, config_value in config.items():
                if config_key == 'golden_sources':
                    golden_sources_config = config_value

        self.__golden_sources_config = golden_sources_config

    def get_config(self):
        return self.__golden_sources_config

    def build(self, config):
        self.set_config(config=config)