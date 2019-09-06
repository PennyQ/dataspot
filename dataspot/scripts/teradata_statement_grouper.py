from dataspot.scripts.statement_grouper import StatementGrouper


class TeradataStatementGrouper:

    def __init__(self, statements):
        self.__statements = statements
        self.__creates_as = None
        self.__creates = None
        self.__insert_intos = None
        self.__updates = None
        self.__deletes = None

    def set_creates_as(self, statements):
        creates_as = StatementGrouper.group_creates_as(statements=statements)
        self.__creates_as = creates_as

    def get_creates_as(self):
        return self.get_creates_as()

    def set_creates(self, statements):
        creates = StatementGrouper.group_creates(statements=statements)
        self.__creates = creates

    def get_creates(self):
        return self.__creates

    def set_insert_intos(self, statements):
        insert_intos = StatementGrouper.group_insert_into(statements=statements)
        self.__insert_intos = insert_intos

    def get_insert_intos(self):
        return self.__insert_intos

    def set_updates(self, statements):
        updates = StatementGrouper.group_updates(statements=statements)
        self.__updates = updates

    def get_updates(self):
        return self.__updates

    def set_deletes(self, statements):
        deletes = StatementGrouper.group_deletes(statements=statements)
        self.__deletes = deletes

    def get_deletes(self):
        return self.__deletes

    def group(self):
        statements = self.__statements
        self.set_creates_as(statements=statements)
        self.set_creates(statements=statements)
        self.set_insert_intos(statements=statements)
        self.set_updates(statements=statements)
        self.set_deletes(statements=statements)

        grouped_statements = dict()
        grouped_statements['create_as'] = self.get_creates_as()
        grouped_statements['create'] = self.get_creates()
        grouped_statements['insert_into'] = self.get_insert_intos()
        grouped_statements['update'] = self.get_updates()
        grouped_statements['delete'] = self.get_deletes()

        return grouped_statements
