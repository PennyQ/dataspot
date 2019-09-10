from pprint import pprint


class StatementGrouper:
    """
    StatementGrouper groups statements belonging to the same type of DML/DDL in the same list. This is done via two
    steps:

        1. Iterate over list of statements and call the respective validate function
        2. If the statements contains the DML/DDL statement the validate function will return True, otherwise False

    When the validate function returns True, the statement will be added to statement list for that type. If False,
    the statement will be added to a new list of statements. These statements thus need to be checked on their type
    of DML/DDL.
    """

    def __init__(self, statements):
        # for statement in statements:
        #     pprint(statement)
        self.__statements = statements
        self.__creates_as = None
        self.__creates = None
        self.__deletes = None
        self.__updates = None
        self.__insert_intos = None

    def set_statements(self, statements):
        self.__statements = statements

    def get_statements(self):
        return self.__statements

    @staticmethod
    def validate_create_as(statement):
        if statement.lower().find('create table') != -1 and statement.lower().find(' as ') != -1 and statement.lower().find(' from ') != -1:
            return True
        else:
            return False

    def set_creates_as(self, creates_as):
        self.__creates_as = creates_as

    def get_creates_as(self):
        return self.__creates_as

    def group_creates_as(self):
        statements = self.get_statements()
        creates_as = list()
        new_statements = list()
        for statement in statements:
            # pprint(statement)
            result = StatementGrouper.validate_create_as(statement=statement)
            if result:
                creates_as.append(statement)
            else:
                new_statements.append(statement)

        self.set_statements(statements=statements)
        self.set_creates_as(creates_as=creates_as)

    @staticmethod
    def validate_create(statement):
        if statement.lower().find('create table') != -1 and statement.lower().find(' as ') == -1:
            return True
        else:
            return False

    def set_creates(self, creates):
        self.__creates = creates

    def get_creates(self):
        return self.__creates

    def group_creates(self):
        statements = self.get_statements()
        creates = list()
        new_statements = list()
        for statement in statements:
            result = StatementGrouper.validate_create(statement=statement)
            if result:
                creates.append(statement)
            else:
                new_statements.append(statement)

        self.set_statements(statements=statements)
        self.set_creates(creates=creates)

    @staticmethod
    def validate_insert_into(statement):
        if statement.lower().find('insert into ') != -1 and statement.lower().find('select ') != -1 and \
                statement.lower().find('from') != -1:
            return True
        else:
            return False

    def set_insert_intos(self, insert_intos):
        self.__insert_intos = insert_intos

    def get_insert_intos(self):
        return self.__insert_intos

    def group_insert_intos(self):
        statements = self.get_statements()
        insert_intos = list()
        new_statements = list()
        for statement in statements:
            # pprint(statement)
            result = StatementGrouper.validate_insert_into(statement=statement)
            if result:
                insert_intos.append(statement)
            else:
                new_statements.append(statement)

        self.set_statements(statements=statements)
        self.set_insert_intos(insert_intos=insert_intos)

    @staticmethod
    def validate_delete(statement):
        if statement.lower().find('delete') != -1:
            return True
        else:
            return False

    def set_deletes(self, deletes):
        self.__deletes = deletes

    def get_deletes(self):
        return self.__deletes

    def group_deletes(self):
        statements = self.get_statements()
        deletes = list()
        new_statements = list()
        for statement in statements:
            result = StatementGrouper.validate_delete(statement=statement)
            if result:
                deletes.append(statement)
            else:
                new_statements.append(statement)

        self.set_statements(statements=statements)
        self.set_deletes(deletes=deletes)

    @staticmethod
    def validate_update(statement):
        if statement.lower().find('update ') != -1:
            return True
        else:
            return False

    def set_updates(self, updates):
        self.__updates = updates

    def get_updates(self):
        return self.__updates

    def group_updates(self):
        statements = self.get_statements()
        updates = list()
        new_statements = list()
        for statement in statements:
            result = StatementGrouper.validate_update(statement=statement)
            if result:
                updates.append(statement)
            else:
                new_statements.append(statement)

        self.set_statements(statements=statements)
        self.set_updates(updates=updates)

    def group(self):
        self.group_creates_as()
        self.group_creates()
        self.group_insert_intos()
        self.group_deletes()
        self.group_updates()

#
# script = open('/Users/patrickdehoon/Projecten/prive/dataspot/examples/test.sql')
# lines = script.readlines()
# script.close()
# statements = list()
# statement_1 = list()
# statement_1.append('.IF')
# statement_1.append('EOP')
# statements.append(statement_1)
# statement_2 = list()
# statement_2.append('COMMENT ON')
# statement_2.append(';')
# statements.append(statement_2)
# statement_3 = list()
# statement_3.append('SET QUERY_BAND')
# statement_3.append(';')
# statements.append(statement_3)
# statement_3 = list()
# statement_3.append('COLLECT STAT')
# statement_3.append(';')
# statements.append(statement_3)
#
# comment_mapping = dict()
# comment_mapping['single_line_comment'] = '--'
# comment_mapping['multi_line_comment'] = ['/*', '*/']
# new_lines = ScriptCleaner().clean(lines=lines, comment_mapping=comment_mapping, statements=statements)
# statements = StatementSeparator.separate(lines=new_lines, statement_end=';')
# # for statement in statements:
# #     print(statement)
# limit = 10000
# sys.setrecursionlimit(limit)
# result = StatementGrouper.group_creates_as(statements=statements)
# for i in result:
#     # print(i)
#     result = ObjectSourceParser(statement=i).parse()
#     # print(result)