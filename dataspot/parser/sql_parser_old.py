from dataspot.parser_old.sql.query_parser_old import QueryParser
import json
import copy


class SQLParser:

    def __init__(self, lines, parser):
        self.__lines = lines
        self.__parser = parser
        self.__creates_as = None
        self.__inserts = None
        self.__views = None

    def get_lines(self):
        lines = copy.deepcopy(self.__lines)
        return lines

    def get_parser(self):
        return self.__parser

    def set_creates_as(self):
        lines = self.get_lines()
        parser = self.get_parser()
        self.__creates_as = QueryParser(lines=lines).execute(parser=parser['create_as'])

    def get_creates_as(self):
        return self.__creates_as

    def set_inserts(self):
        lines = self.get_lines()
        parser = self.get_parser()
        self.__inserts = QueryParser(lines=lines).execute(parser=parser['insert'])

    def get_inserts(self):
        return self.__inserts

    def set_views(self):
        lines = self.get_lines()
        parser = self.get_parser()
        self.__views = QueryParser(lines=lines).execute(parser=parser['replace'])

    def get_views(self):
        return self.__views

    def execute(self):
        self.set_creates_as()
        self.set_inserts()
        self.set_views()



file = open('/Users/patrickdehoon/Projecten/prive/dataspot/dataspot/dataspot_parser_config.json')
parser = json.load(file)
file.close()

script = open('/Users/patrickdehoon/Projecten/prive/dataspot/examples/test.sql')
lines = script.readlines()
sql_parser = SQLParser(lines=lines, parser=parser['sql_parser'])
sql_parser.execute()
result_create = sql_parser.get_creates_as()
result_insert = sql_parser.get_inserts()
result_view = sql_parser.get_views()
print(1,result_create)
print(2,result_insert)
print(3,result_view)
# for i in result:
#     print(i)



#
# td_parser = {'create': [['create table', 'as'], [';']]}
# t_parser = {'create': [['select', 'into',  'from'], [';']]}
# ora_parser = {'create': [['create table', 'as'], [';']]}
# ps_parser = {'create': [['create table', 'as'], [';']]}
#
# test_parser = {"sql_parser": {"create": [['create table', 'as'], [';']]}}
# test2_parser = {'create': [['t_sql_parser'], ['select', 'into',  'from'], [';']]}
#

# # print(1, lines[0], 2)
# result = SQLParser(lines=lines).execute(parser_old=td_parser)
# script.close()
# # result = SQLParser.list_creates(script=script, parser_old=td_parser)
# # print(result)
# for i in result:
#     print(i)