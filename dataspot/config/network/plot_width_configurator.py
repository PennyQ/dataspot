from dataspot.config.configurator import Configurator


class PlotWidthConfigurator(Configurator):
    """

    """

    def __init__(self, config):
        self.__config = config
        self.__plot_width = None

    def set_config(self, config):
        self.__config = config

    def get_config(self):
        return self.__config

    def set_plot_width_config(self, config):
        plot_width = None
        for config in config['network_config']:
            for config_key, config_value in config.items():
                if config_key == 'plot_width':
                    plot_width = config_value

        self.__plot_width = plot_width

    def get_plot_width_config(self):
        return self.__plot_width

    def build(self):
        config = self.get_config()
        self.set_plot_width_config(config=config)
