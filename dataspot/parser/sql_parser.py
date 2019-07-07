from dataspot.parser.sql.create_as_parser import CreateAsParser


class SQLParser:

    def __init__(self, lines, parser):
        self.lines = lines
        self.parser = parser
        self.creates_as = None

    def set_creates_as(self):
        self.creates_as = CreateAsParser(lines=self.lines).execute(parser=self.parser)

    def execute(self):
        self.set_creates_as()



#
# td_parser = {'create': [['create table', 'as'], [';']]}
# t_parser = {'create': [['select', 'into',  'from'], [';']]}
# ora_parser = {'create': [['create table', 'as'], [';']]}
# ps_parser = {'create': [['create table', 'as'], [';']]}
#
# test_parser = {"sql_parser": {"create": [['create table', 'as'], [';']]}}
# test2_parser = {'create': [['t_sql_parser'], ['select', 'into',  'from'], [';']]}
#
# script = open('/Users/patrickdehoon/Projecten/prive/dataspot/examples/test.sql')
# lines = script.readlines()
# # print(1, lines[0], 2)
# result = SQLParser(lines=lines).execute(parser=td_parser)
# script.close()
# # result = SQLParser.list_creates(script=script, parser=td_parser)
# # print(result)
# for i in result:
#     print(i)