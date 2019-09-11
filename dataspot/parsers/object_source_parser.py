import abc


class ObjectSourceParser(metaclass=abc.ABCMeta):
    """
    The ObjectSourceParser returns a list of all the sources used in a statement.
    """

    @staticmethod
    @abc.abstractmethod
    def list_unique_sources(source_list):
        pass

    @staticmethod
    @abc.abstractmethod
    def find_source(source_key, statement):
        pass

    @staticmethod
    @abc.abstractmethod
    def list_sources(source_key, source_list, statement):
        pass

    @abc.abstractmethod
    def set_source_list(self, source_list):
        pass

    @abc.abstractmethod
    def get_source_list(self):
        pass

    @abc.abstractmethod
    def get_source_keys(self):
        pass

    @abc.abstractmethod
    def set_statement(self, statement):
        pass

    @abc.abstractmethod
    def get_statement(self):
        pass

    @abc.abstractmethod
    def parse_sources(self):
        pass

    @abc.abstractmethod
    def parse(self):
        pass
