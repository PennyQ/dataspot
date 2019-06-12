from dataspot.config.configurator import Configurator


class PlotHeightConfigurator(Configurator):

    def __init__(self):
        self.__plot_height = None

    def set_config(self, config):
        plot_height = None
        for config in config['network_config']:
            for config_key, config_value in config.items():
                if config_key == 'plot_height':
                    plot_height = config_value

        self.__plot_height = plot_height

    def get_config(self):
        return self.__plot_height

    def build(self, config):
        self.set_config(config=config)
