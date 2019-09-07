from dataspot.parsers.object_name_parser import ObjectNameParser
from dataspot.parsers.parser import Parser


class TeradataParser(Parser):

    def __init__(self):
        self.__object_names = None

    def set_object_names(self, statements):
        object_names_insert_into = ObjectNameParser.parse_object_names(statements=statements, start_key='insert into',
                                                                       end_key='select')

        object_names_create_as = ObjectNameParser.parse_object_names(statements=statements, start_key='create table',
                                                                     end_key=' as ')

        object_names = object_names_insert_into + object_names_create_as
        self.__object_names = object_names

    def get_object_names(self):
        return self.__object_names

    def find_from_source(self):
        pass

    def set_from_sources(self, statements):
        pass

    def get_from_sources(self):
        pass

    def set_join_sources(self):
        pass

    def get_join_sources(self):
        pass

    def group_sources(self):
        join_sources = self.get_join_sources()
        from_sources = None

    def parse(self, statements):
        pass
