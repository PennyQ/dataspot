from dataspot.parsers.object_source_helper import ObjectSourceHelper
from dataspot.parsers.object_source_parser import ObjectSourceParser


class TeradataObjectSourceParser(ObjectSourceParser):

    def __init__(self, source_keys, statement):
        """
        :param source_keys: A list containing values indicating a source is behind that value
        :type source_keys: List
        :param statement: A (SQL) code statement
        :type statement: String
        """
        self.__source_list = list()
        self.__source_keys = source_keys
        self.__statement = statement

    @staticmethod
    def list_unique_sources(source_list):
        source_list = list(set(source_list))
        return source_list

    @staticmethod
    def find_source(source_key, statement):
        source = None
        if statement.find(source_key) != -1:
            source = statement[statement.find(source_key) + len(source_key)+1: len(statement)].strip()
            # print(1, source)
            source = source[:source.find(" ")]
            # print(2, source)
            source_result = ObjectSourceHelper.validate_source(source=source)
            source, statement = ObjectSourceHelper.adjust_statement(source=source, source_result=source_result,
                                                                    source_key=source_key, statement=statement)

            return source, statement
        elif statement.find('create table') != -1 and statement.find(' as ') != -1 and statement.find('from') == -1:
            source = statement[statement.find(' as ')+4: statement.find(' with data ')]
            statement = ""
            return source, statement
        else:
            statement = ""
            return source, statement

    @staticmethod
    def list_sources(source_key, source_list, statement):
        statement_list = [statement]
        for statement in statement_list:
            source, adjusted_statement = TeradataObjectSourceParser.find_source(source_key=source_key, statement=statement)
            if source:
                source_list.append(source)
            if len(adjusted_statement) > 0:
                statement_list.append(adjusted_statement)
        return source_list

    def set_source_list(self, source_list):
        self.__source_list = source_list

    def get_source_list(self):
        return self.__source_list

    def get_source_keys(self):
        return self.__source_keys

    def set_statement(self, statement):
        self.__statement = statement

    def get_statement(self):
        return self.__statement

    def parse_sources(self):
        source_list = self.get_source_list()
        source_keys = self.get_source_keys()
        statement = self.get_statement()

        for source_key in source_keys:
            sources = self.list_sources(source_key=source_key, source_list=source_list, statement=statement)
            source_list = source_list + sources

        source_list = self.list_unique_sources(source_list=source_list)
        self.set_source_list(source_list=source_list)

    def parse(self):
        statement = self.__statement
        statement = ObjectSourceHelper.create_source_statement(statement=statement)
        self.set_statement(statement=statement)
        self.parse_sources()
