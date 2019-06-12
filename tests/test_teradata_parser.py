import unittest
from dataspot.parser.teradata_parser import TeradataParser


class TestTeradataParser(unittest.TestCase):

    def setUp(self):
        self.__script = '/Users/patrickdehoon/PycharmProjects/Dataspot/tests/scripts/valid_scripts/dataspot_script_test.sql'
        self.__creates = ['CREATE TABLE GENERAL.TEST3 AS\n  (SELECT *\n   FROM GENERAL.TEST1)\nWITH DATA AND STATS;\n']
        self.__inserts = ['INSERT INTO GENERAL.TEST2\nSELECT *\nFROM GENERAL.TEST1;\n']
        self.__insert_query = 'INSERT INTO GENERAL.TEST2\nSELECT *\nFROM GENERAL.TEST1;\n'
        self.__create_query = 'CREATE TABLE GENERAL.TEST3 AS\n  (SELECT *\n   FROM GENERAL.TEST1)\nWITH DATA AND STATS;\n'
        self.__queries = ['INSERT INTO GENERAL.TEST2\nSELECT *\nFROM GENERAL.TEST1;\n', 'CREATE TABLE GENERAL.TEST3 AS\n  (SELECT *\n   FROM GENERAL.TEST1)\nWITH DATA AND STATS;\n']
        self.__table_keys = ['general.test2', 'general.test3']
        self.__options = ['insert into', 'create table']
        self.__from_statement = 'from general.test1'

    def test_list_creates(self):
        script = self.__script
        teradata_parser = TeradataParser()
        result = teradata_parser.list_creates(script=script)
        print("test_list_creates", result)

    def test_list_inserts(self):
        script = self.__script
        teradata_parser = TeradataParser()
        result = teradata_parser.list_inserts(script=script)
        print("test_list_inserts", result)

    def test_list_queries(self):
        creates = self.__creates
        inserts = self.__inserts
        teradata_parser = TeradataParser()
        result = teradata_parser.list_queries(creates=creates, inserts=inserts)
        print("test_list_queries", result)

    def test_list_table_name(self):
        insert_query = self.__insert_query
        create_query = self.__create_query

        teradata_parser = TeradataParser()
        result_insert = teradata_parser.list_table_name(query=insert_query)
        result_create = teradata_parser.list_table_name(query=create_query)
        print("test_list_table_name | inserts", result_insert)
        print("test_list_table_name | creates", result_create)

    def test_table_keys_and_options(self):
        queries = self.__queries
        teradata_parser = TeradataParser()
        result_keys, result_options = teradata_parser.list_table_keys_and_options(queries=queries)
        print("test_table_keys_and_options | keys", result_keys)
        print("test_table_keys_and_options | options", result_options)

    def test_list_relationships(self):
        queries = self.__queries
        table_keys = self.__table_keys
        options = self.__options
        teradata_parser = TeradataParser()
        result = teradata_parser.list_relationships(queries=queries, table_keys=table_keys, options=options)
        print("test_list_relationships", result)

    def test_list_from_statement(self):
        query = self.__queries[0]
        table_name = self.__table_keys[0]
        option = self.__options[0]
        teradata_parser = TeradataParser()
        result = teradata_parser.list_from_statement(query=query, table_name=table_name, option=option)
        print("test_list_from_statement", result)

    def test_list_table_sources(self):
        teradata_parser = TeradataParser()
        from_statement = self.__from_statement
        adjusted_from_statement = from_statement
        adjustable_from_statement = str()
        sources = list()
        source = str()
        froms_or_joins = 0
        deepest_level_ind = 0

        result = teradata_parser.list_table_sources(from_statement=from_statement,
                                                    adjusted_from_statement=adjusted_from_statement,
                                                    adjustable_from_statement=adjustable_from_statement,
                                                    sources=sources, source=source, froms_or_joins=froms_or_joins,
                                                    deepest_level_ind=deepest_level_ind)

        print("test_list_table_sources", result)

    def tearDown(self):
        pass


if __name__ == '__main__':
    unittest.main()