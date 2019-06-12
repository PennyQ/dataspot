

class SQLParser:

    def __init__(self):
        pass

    @staticmethod
    def list_creates(script, parser):
        creates = list()
        query_found = 0
        query = ""

        with open(script, 'r') as f:
            f = f.readlines()
            for i in f:
                if i.lower().find(parser['create'][0]) != -1 and query_found == 0:
                    query_found = 1
                    query += i
                elif query_found == 1 and i.lower().find(parser['create'][-1]) != -1:
                    query += i
                    if parser['create'][1] != ';' and query.lower().find(parser['create'][1]) != -1:
                        creates.append(query)
                        query = ""
                        query_found = 0
                    else:
                        query = ""
                        query_found = 0
                elif query_found == 1:
                    query += i
                else:
                    pass

        with open(script, 'r') as f:
            f = f.readlines()
            for i in f:
                pass

        return creates


td_parser = {'create': ['create table', 'as', ';']}
t_parser = {'create': ['select', 'into', ';']}
ora_parser = {'create': ['create table', 'as', ';']}

script = '/Users/patrickdehoon/PycharmProjects/Dataspot/examples/clan/scripts/1b.sql'
print(td_parser['create'][0])

result = SQLParser.list_creates(script=script, parser=td_parser)

for i in result:
    print(i)