import abc


class Parser(metaclass=abc.ABCMeta):

    @abc.abstractmethod
    def get_parser_config(self):
        pass

    @abc.abstractmethod
    def get_scripts(self):
        pass

    @abc.abstractmethod
    def set_comment_mapping(self):
        pass

    @abc.abstractmethod
    def get_comment_mapping(self):
        pass

    @abc.abstractmethod
    def set_unnecessary_statements(self):
        pass

    @abc.abstractmethod
    def get_unnecessary_statements(self):
        pass

    @abc.abstractmethod
    def set_statement_end(self):
        pass

    @abc.abstractmethod
    def get_statement_end(self):
        pass

    @abc.abstractmethod
    def set_name_keys(self):
        pass

    @abc.abstractmethod
    def get_name_keys(self):
        pass

    @abc.abstractmethod
    def set_source_keys(self):
        pass

    @abc.abstractmethod
    def get_source_keys(self):
        pass

    @abc.abstractmethod
    def clean_scripts(self):
        pass

    @abc.abstractmethod
    def set_grouped_statements(self, grouped_statements):
        pass

    @abc.abstractmethod
    def get_grouped_statements(self):
        pass

    @abc.abstractmethod
    def build_grouped_statements(self):
        pass

    @abc.abstractmethod
    def set_statements(self, statements):
        pass

    @abc.abstractmethod
    def get_statements(self):
        pass

    @abc.abstractmethod
    def build_statements(self):
        pass

    @abc.abstractmethod
    def set_relationships(self, relationships):
        pass

    @abc.abstractmethod
    def get_relationships(self):
        pass

    @abc.abstractmethod
    def build_relationships(self):
        pass

    @abc.abstractmethod
    def parse(self):
        pass
