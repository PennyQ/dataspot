

class ObjectSourceParser:

    def __init__(self, statement):
        self.__source_list = list()
        self.__statement = statement

    @staticmethod
    def find_from_source(statement):
        source = None

        if statement.find('from') != -1:
            source = statement[statement.find('from') + 5: len(statement)]
            print(99, source)
            statement = statement[statement.find(source):len(statement)]
            return source, statement
        else:
            statement = ""
            return source, statement

    @staticmethod
    def clean_statement(statement):
        statement = statement.replace('both from', '')
        statement = statement.replace('day from', '')
        statement = statement.replace('month from', '')
        statement = statement.replace('year from', '')
        return statement

    @staticmethod
    def create_source_statement(statement):
        source_statement = None
        statement = ObjectSourceParser.clean_statement(statement=statement)
        if statement.find('from') != -1:
            source_statement = statement[statement.find('from'): len(statement)]
            return source_statement
        return source_statement

    @staticmethod
    def list_from_sources(source_list, statement):
        if len(statement) > 0:
            source, statement = ObjectSourceParser.find_from_source(statement=statement)
            if source:
                source_list.append(source)
            return statement, source_list
        else:
            return source_list, statement

    def parse(self):
        statement = self.__statement
        statement = self.create_source_statement(statement=statement)
        self.__statement = statement
        source_list, statement = self.list_from_sources(source_list=self.__source_list, statement=self.__statement)

        return source_list
