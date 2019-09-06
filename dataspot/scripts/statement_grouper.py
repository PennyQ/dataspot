from dataspot.scripts.script_cleaner import ScriptCleaner
from dataspot.scripts.statement_separator import StatementSeparator


class StatementGrouper:

    @staticmethod
    def find_create_as(statement):
        if statement.lower().find('create') != -1 and statement.lower().find(' as ') != -1:
            return True
        else:
            return False

    @staticmethod
    def group_creates_as(statements):
        creates_as = list()
        for statement in statements:
            result = StatementGrouper.find_create_as(statement=statement)
            if result:
                print(statement)
                creates_as.append(statement)
        return creates_as

    @staticmethod
    def find_create(statement):
        if statement.lower().find('create') != -1 and statement.lower().find(' as ') == -1:
            return True
        else:
            return False

    @staticmethod
    def group_creates(statements):
        creates = list()
        for statement in statements:
            result = StatementGrouper.find_create(statement=statement)
            if result:
                print(statement)
                creates.append(statement)
        return creates

    @staticmethod
    def find_delete(statement):
        if statement.lower().find('delete') != -1:
            return True
        else:
            return False

    @staticmethod
    def group_deletes(statements):
        deletes = list()
        for statement in statements:
            result = StatementGrouper.find_delete(statement=statement)
            if result:
                deletes.append(statement)
        return deletes

    @staticmethod
    def find_insert_into(statement):
        if statement.lower().find('insert into') != -1:
            return True
        else:
            return False

    @staticmethod
    def group_insert_into(statements):
        insert_intos = list()
        for statement in statements:
            result = StatementGrouper.find_insert_into(statement=statement)
            if result:
                insert_intos.append(statement)
        return insert_intos

    @staticmethod
    def find_update(statement):
        if statement.lower().find('update') != -1:
            return True
        else:
            return False

    @staticmethod
    def group_updates(statements):
        insert_intos = list()
        for statement in statements:
            result = StatementGrouper.find_update(statement=statement)
            if result:
                insert_intos.append(statement)
        return insert_intos


script = open('/Users/patrickdehoon/Projecten/prive/dataspot/examples/test.sql')
lines = script.readlines()
script.close()
statements = list()
statement_1 = list()
statement_1.append('.IF')
statement_1.append('EOP')
statements.append(statement_1)
statement_2 = list()
statement_2.append('COMMENT ON')
statement_2.append(';')
statements.append(statement_2)
statement_3 = list()
statement_3.append('SET QUERY_BAND')
statement_3.append(';')
statements.append(statement_3)
statement_3 = list()
statement_3.append('COLLECT STAT')
statement_3.append(';')
statements.append(statement_3)

comment_mapping = dict()
comment_mapping['single_line_comment'] = '--'
comment_mapping['multi_line_comment'] = ['/*', '*/']
new_lines = ScriptCleaner().clean(lines=lines, comment_mapping=comment_mapping, statements=statements)
statements = StatementSeparator.separate(lines=new_lines, statement_end=';')
# for statement in statements:
#     print(statement)
result = StatementGrouper.group_creates(statements=statements)
