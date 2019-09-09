from dataspot.parsers.object_name_parser import ObjectNameParser
from dataspot.parsers.object_source_parser import ObjectSourceParser
from dataspot.scripts.script_cleaner import ScriptCleaner
from dataspot.scripts.script_separator import ScriptSeparator
from dataspot.scripts.statement_grouper import StatementGrouper
from dataspot.parsers.parser import Parser


class TeradataParser(Parser):

    def __init__(self, parser_mapping, scripts):
        self.__parser_mapping= parser_mapping
        self.__comment_mapping = None
        self.__unnecessary_statements = None
        self.__statement_end = None
        self.__find_keys = None
        self.__grouped_statements = None
        self.__relationships = None
        self.__scripts = scripts

    def get_parser_mapping(self):
        return self.__parser_mapping

    def get_scripts(self):
        return self.__scripts

    def set_comment_mapping(self):
        parser_mapping = self.get_parser_mapping()
        comment_mapping = parser_mapping['comment_mapping']
        self.__comment_mapping = comment_mapping

    def get_comment_mapping(self):
        return self.__comment_mapping

    def set_unnecessary_statements(self):
        parser_mapping = self.get_parser_mapping()
        unnecessary_statements = parser_mapping['unnecessary_statements']
        self.__unnecessary_statements = unnecessary_statements

    def get_unnecessary_statements(self):
        return self.__unnecessary_statements

    def set_statement_end(self):
        parser_mapping = self.get_parser_mapping()
        statement_end = parser_mapping['statement_end']
        self.__statement_end = statement_end

    def get_statement_end(self):
        return self.__statement_end

    def set_find_keys(self):
        parser_mapping = self.get_parser_mapping()
        find_keys = parser_mapping['find_keys']
        self.__find_keys = find_keys

    def get_find_keys(self):
        return self.__find_keys

    def clean_script(self, script):
        comment_mapping = self.get_comment_mapping()
        unnecessary_statements = self.get_unnecessary_statements()
        script = ScriptCleaner(comment_mapping=comment_mapping).clean(lines=script, statements=unnecessary_statements)
        return script

    def separate_script(self, script):
        statement_end = self.get_statement_end()
        statements = ScriptSeparator.separate(script=script, statement_end=statement_end)
        return statements

    def set_relationships(self, statements):
        pass

    def get_relationships(self):
        return self.__relationships

    def build_relationships(self, statements):
        relationships = dict()
        for statement in statements:
            object_name = ObjectNameParser.parse_object_name(statement=statement)
            object_sources = ObjectSourceParser(statement=statement).parse()
            relationships[object_name] = object_sources

    def set_grouped_statements(self, grouped_statements):
        self.__grouped_statements = grouped_statements

    def get_grouped_statements(self):
        return self.__grouped_statements

    def build_statements(self, statements):
        grouped_statements = dict()
        statement_grouper = StatementGrouper(statements=statements)
        statement_grouper.group()
        grouped_statements['insert_into'] = statement_grouper.get_insert_intos()
        grouped_statements['create_as'] = statement_grouper.get_creates_as()
        self.set_grouped_statements(grouped_statements=grouped_statements)

    def group_sources(self):
        pass

    def parse(self):
        scripts = self.get_scripts()
        for script in scripts:
            script = open(script)
            lines = script.readlines()
            script.close()
            lines = self.clean_script(script=lines)
            statements = self.separate_script(script=lines)
            self.build_statements(statements=statements)
            self.build_relationships(statements=statements)
