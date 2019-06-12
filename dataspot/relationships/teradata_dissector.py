from dataspot.relationships.sql_dissector import SQLDissector
from dataspot.parser.teradata_parser import TeradataParser


class TeradataDissector(SQLDissector):

    def __init__(self):
        self.__creates = None
        self.__inserts = None
        self.__views = None
        self.__queries = None
        self.__table_keys = None
        self.__options = None
        self.__relationships = None

    def set_creates(self, script):
        self.__creates = TeradataParser.list_creates(script=script)

    def set_inserts(self, script):
        self.__inserts = TeradataParser.list_inserts(script=script)

    def set_views(self, script):
        self.__views = TeradataParser.list_views(script=script)

    def set_updates(self, script):
        pass

    def set_deletes(self, script):
        pass

    def set_queries(self, inserts, creates, views):
        self.__queries = TeradataParser.list_queries(inserts=inserts, creates=creates, views=views)

    def set_table_keys_and_options(self, queries):
        self.__table_keys, self.__options = TeradataParser.list_table_keys_and_options(queries=queries)

    def set_relationships(self, queries, table_keys, options):
        self.__relationships = TeradataParser.list_relationships(queries=queries, table_keys=table_keys,
                                                                 options=options)

    def create_relationships(self, script):
        self.set_creates(script=script)
        self.set_inserts(script=script)
        self.set_views(script=script)
        self.set_queries(inserts=self.__inserts, creates=self.__creates, views=self.__views)
        self.set_table_keys_and_options(queries=self.__queries)
        self.set_relationships(queries=self.__queries, table_keys=self.__table_keys, options=self.__options)

        return self.__relationships

