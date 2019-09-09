from dataspot.parsers.object_source_helper import ObjectSourceHelper


class ObjectSourceParser:
    """
    The ObjectSourceParser returns a list of all the sources used in a statement.
    """

    def __init__(self, find_keys, statement):
        """
        :param find_keys: A list containing values indicating a source is behind that value
        :param statement: A (SQL) code statement
        """
        self.__source_list = list()
        self.__find_keys = find_keys
        self.__statement = statement

    @staticmethod
    def list_unique_sources(source_list):
        source_list = list(set(source_list))
        return source_list

    @staticmethod
    def find_source(find_key, statement):
        source = None
        if statement.find(find_key) != -1:
            source = statement[statement.find(find_key) + len(find_key)+1: len(statement)].rstrip()
            source = source[:source.find(" ")]
            source_result = ObjectSourceHelper.validate_source(source=source)
            source, statement = ObjectSourceHelper.adjust_statement(source=source, source_result=source_result,
                                                                    find_key=find_key, statement=statement)
            return source, statement
        else:
            statement = ""
            return source, statement

    @staticmethod
    def list_sources(find_key, source_list, statement):
        statement_list = [statement]
        for statement in statement_list:
            source, adjusted_statement = ObjectSourceParser.find_source(find_key=find_key, statement=statement)
            if source:
                source_list.append(source)
            if len(adjusted_statement) > 0:
                statement_list.append(adjusted_statement)
        return source_list

    def set_source_list(self, source_list):
        self.__source_list = source_list

    def get_source_list(self):
        return self.__source_list

    def get_find_keys(self):
        return self.__find_keys

    def set_statement(self, statement):
        self.__statement = statement

    def get_statement(self):
        return self.__statement

    def parse_sources(self):
        source_list = self.get_source_list()
        find_keys = self.get_find_keys()
        statement = self.get_statement()

        for find_key in find_keys:
            sources = self.list_sources(find_key=find_key, source_list=source_list, statement=statement)
            source_list = source_list + sources

        source_list = ObjectSourceParser.list_unique_sources(source_list=source_list)
        self.set_source_list(source_list=source_list)

    def parse(self):
        statement = self.__statement
        statement = ObjectSourceHelper.create_source_statement(statement=statement)
        self.set_statement(statement=statement)
        self.parse_sources()
