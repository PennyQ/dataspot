from dataspot.parser.sql.query_parser import QueryParser
import json
import copy



class SQLParser:

    def __init__(self, lines, parser):
        self.__lines = lines
        self.__parser = parser
        self.__creates = None
        self.__inserts = None
        self.__views = None
        self.__deletes = None
        self.__updates = None

    def get_lines(self):
        lines = copy.deepcopy(self.__lines)
        return lines

    def get_parser(self):
        return self.__parser

    def set_parser(self, dialect):
        """
        The SQL-parser is standard loaded with a sql subset of the original parser configuration file. Since, every
        SQL-dialect follows the same interface, only a dialect specification is needed to narrow down the subset.

        :param dialect: Set the specific sql-dialect required for parsing the script
        :return: None
        """
        parser = self.get_parser()
        parser = parser[type][dialect]
        self.__parser = parser

    def set_creates(self, dialect):
        lines = self.get_lines()
        parser = self.get_parser()
        create_parser = parser['create']
        query_parser = QueryParser()
        query_parser.parse_creates(parser=create_parser, lines=lines)
        creates = QueryParser.get_creates()
        self.__creates = creates

    def set_inserts(self, dialect):
        lines = self.get_lines()
        parser = self.get_parser()
        insert_parser = parser['insert']
        query_parser = QueryParser(lines=lines, parser=insert_parser)
        query_parser.parse_inserts(dialect=dialect)
        creates = QueryParser.get_creates()
        self.__creates = creates

    def set_views(self, dialect):
        lines = self.get_lines()
        parser = self.get_parser()
        view_parser = parser['view']
        query_parser = QueryParser(lines=lines, parser=view_parser)
        query_parser.parse_views(dialect=dialect)
        creates = QueryParser.get_creates()
        self.__creates = creates

    def set_deletes(self, dialect):
        lines = self.get_lines()
        parser = self.get_parser()
        delete_parser = parser['delete']
        query_parser = QueryParser(lines=lines, parser=delete_parser)
        query_parser.parse_deletes(dialect=dialect)
        creates = QueryParser.get_creates()
        self.__creates = creates

    def set_updates(self, dialect):
        lines = self.get_lines()
        parser = self.get_parser()
        update_parser = parser['update']
        query_parser = QueryParser(lines=lines, parser=update_parser)
        query_parser.parse_updates(dialect=dialect)
        creates = QueryParser.get_creates()
        self.__creates = creates

    def execute(self, dialect):
        self.set_parser(dialect=dialect)
        self.set_creates(dialect=dialect)
        self.set_inserts(dialect=dialect)
        self.set_views(dialect=dialect)
        self.set_deletes(dialect=dialect)
        self.set_updates(dialect=dialect)
