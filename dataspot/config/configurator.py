import abc


class Configurator(metaclass=abc.ABCMeta):
    """

    """

    @abc.abstractmethod
    def set_config(self, config):
        pass

    @abc.abstractmethod
    def get_config(self):
        pass

    @abc.abstractmethod
    def build(self):
        pass
