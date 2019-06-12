import abc


class Visualizer(metaclass=abc.ABCMeta):

    @abc.abstractmethod
    def set_source(self):
        pass

    @abc.abstractmethod
    def get_source(self):
        pass

    @abc.abstractmethod
    def set_layout(self):
        pass

    @abc.abstractmethod
    def get_layout(self):
        pass

    @abc.abstractmethod
    def build(self):
        pass
