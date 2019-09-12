from dataspot.config.configurator import Configurator


class NodeSizeConfigurator(Configurator):
    """

    """

    def __init__(self,  config):
        self.__config = config
        self.__node_size_config = None

    def set_config(self, config):
        self.__config = config

    def get_config(self):
        return self.__config

    def set_node_size_config(self, config):
        node_size_config = None
        for config in config['network_config']:
            for config_key, config_value in config.items():
                if config_key == 'node_size_config':
                    node_size_config = config_value

        self.__node_size_config = node_size_config

    def get_node_size_config(self):
        return self.__node_size_config

    def build(self):
        config = self.get_config()
        self.set_node_size_config(config=config)
