import abc


class NodeNetworker(metaclass=abc.ABCMeta):

    @abc.abstractmethod
    def set_node(self):
        pass

    @abc.abstractmethod
    def get_node(self):
        pass

    @abc.abstractmethod
    def build(self):
        pass
