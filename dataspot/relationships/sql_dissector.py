import abc


class SQLDissector(metaclass=abc.ABCMeta):

    @abc.abstractmethod
    def set_creates(self, script):
        pass

    @abc.abstractmethod
    def set_inserts(self, script):
        pass

    @abc.abstractmethod
    def set_views(self, script):
        pass

    @abc.abstractmethod
    def set_updates(self, script):
        pass

    @abc.abstractmethod
    def set_deletes(self, script):
        pass

    @abc.abstractmethod
    def set_queries(self, inserts, creates, views, updates, deletes):
        pass

    @abc.abstractmethod
    def set_table_keys_and_options(self, queries):
        pass

    @abc.abstractmethod
    def set_relationships(self, queries, table_keys, options):
        pass

    @abc.abstractmethod
    def create_relationships(self, script):
        pass