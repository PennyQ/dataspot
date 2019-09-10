from dataspot.parsers.object_name_parser import ObjectNameParser
from dataspot.parsers.object_source_parser import ObjectSourceParser
from dataspot.scripts.script_cleaner import ScriptCleaner
from dataspot.scripts.script_separator import ScriptSeparator
from dataspot.scripts.statement_grouper import StatementGrouper
from dataspot.parsers.parser import Parser


class TeradataParser(Parser):

    def __init__(self, parser_mapping, scripts):
        self.__parser_mapping= parser_mapping
        self.__scripts = scripts
        self.__comment_mapping = None
        self.__unnecessary_statements = None
        self.__statement_end = None
        self.__source_keys = None
        self.__name_keys = None
        self.__grouped_statements = None
        self.__relationships = None
        self.__statements = None

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

    def set_name_keys(self):
        parser_mapping = self.get_parser_mapping()
        name_keys = parser_mapping['name_keys']
        self.__name_keys = name_keys

    def get_name_keys(self):
        return self.__name_keys

    def set_source_keys(self):
        parser_mapping = self.get_parser_mapping()
        find_keys = parser_mapping['source_keys']
        self.__source_keys = find_keys

    def get_source_keys(self):
        return self.__source_keys

    def transform_scripts(self):
        scripts = self.get_scripts()
        transformed_scripts = list()
        for script in scripts:
            script = open(script)
            lines = script.readlines()
            script.close()
            transformed_scripts.append(lines)
        self.__scripts = transformed_scripts

    def clean_scripts(self):
        scripts = self.get_scripts()
        comment_mapping = self.get_comment_mapping()
        unnecessary_statements = self.get_unnecessary_statements()
        cleaned_scripts = list()
        for script in scripts:
            script = ScriptCleaner(comment_mapping=comment_mapping).clean(lines=script, statements=unnecessary_statements)
            cleaned_scripts.append(script)
        self.__scripts = cleaned_scripts

    def set_statements(self, statements):
        self.__statements = statements

    def get_statements(self):
        return self.__statements

    def build_statements(self):
        scripts = self.get_scripts()
        statement_end = self.get_statement_end()
        statements = list()
        for script in scripts:
            found_statements = ScriptSeparator.separate(script=script, statement_end=statement_end)
            statements = statements + found_statements
        self.set_statements(statements)

    def set_grouped_statements(self, grouped_statements):
        self.__grouped_statements = grouped_statements

    def get_grouped_statements(self):
        return self.__grouped_statements

    def build_grouped_statements(self):
        statements = self.get_statements()
        grouped_statements = dict()
        statement_grouper = StatementGrouper(statements=statements)
        statement_grouper.group()
        grouped_statements['insert_into'] = statement_grouper.get_insert_intos()
        grouped_statements['create_as'] = statement_grouper.get_creates_as()
        self.set_grouped_statements(grouped_statements=grouped_statements)

    def set_relationships(self, relationships):
        self.__relationships = relationships

    def get_relationships(self):
        return self.__relationships

    def build_relationships(self):
        relationships = dict()
        name_keys = self.get_name_keys()
        source_keys = self.get_source_keys()
        grouped_statements = self.get_grouped_statements()

        for key in grouped_statements.keys():
            start_key = name_keys[key][0]
            end_key = name_keys[key][1]
            for statement in grouped_statements[key]:
                object_name = ObjectNameParser.parse_object_name(statement=statement, start_key=start_key,
                                                                 end_key=end_key)
                object_source_parser = ObjectSourceParser(source_keys=source_keys, statement=statement)
                object_source_parser.parse()
                sources = object_source_parser.get_source_list()
                relationships[object_name] = sources

        self.set_relationships(relationships=relationships)

    def parse(self):
        self.set_comment_mapping()
        self.set_unnecessary_statements()
        self.set_statement_end()
        self.set_name_keys()
        self.set_source_keys()
        self.transform_scripts()
        self.clean_scripts()
        self.build_statements()
        self.build_grouped_statements()
        self.build_relationships()
