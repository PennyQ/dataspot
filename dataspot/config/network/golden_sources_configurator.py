from dataspot.config.configurator import Configurator


class GoldenSourcesConfigurator(Configurator):
    """
    IDEA: Put the explanation for a concept here

    """

    def __init__(self, config):
        self.__config = config
        self.__golden_sources_config = None

    def set_config(self, config):
        self.__config = config

    def get_config(self):
        return self.__config

    def set_golden_sources_config(self, config):
        golden_sources_config = None
        for config in config['network_config']:
            for config_key, config_value in config.items():
                if config_key == 'golden_sources':
                    golden_sources_config = config_value

        self.__golden_sources_config = golden_sources_config

    def get_golden_sources_config(self):
        return self.__golden_sources_config

    def build(self):
        config = self.get_config()
        self.set_golden_sources_config(config=config)
