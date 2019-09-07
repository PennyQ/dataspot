import abc


class Parser(metaclass=abc.ABCMeta):

    @abc.abstractmethod
    def group_sources(self):
        pass

    @abc.abstractmethod
    def parse(self):
        pass
