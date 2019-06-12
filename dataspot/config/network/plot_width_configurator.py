from dataspot.config.configurator import Configurator


class PlotWidthConfigurator(Configurator):

    def __init__(self):
        self.__plot_width = None

    def set_config(self, config):
        plot_width = None
        for config in config['network_config']:
            for config_key, config_value in config.items():
                if config_key == 'plot_width':
                    plot_width = config_value

        self.__plot_width = plot_width

    def get_config(self):
        return self.__plot_width

    def build(self, config):
        self.set_config(config=config)
