from dataspot.scripts.statement_grouper import StatementGrouper


class TeradataStatementGrouper(StatementGrouper):
    """

    """

    def __init__(self, statements):
        """
        :param statements:
        :type statements:
        """
        self.__statements = statements
        self.__creates_as = None
        self.__creates = None
        self.__insert_intos = None
        self.__updates = None
        self.__deletes = None
        self.__create_views = None
        self.__replace_views = None
        self.__create_replace_views = None

    def set_statements(self, statements):
        """
        :param statements:
        :type statements:
        """
        self.__statements = statements

    def get_statements(self):
        """
        :return:
        :rtype:
        """
        return self.__statements

    def set_creates_as(self, creates_as):
        """
        :param creates_as:
        :type creates_as:
        """
        self.__creates_as = creates_as

    def get_creates_as(self):
        """
        :return:
        :rtype:
        """
        return self.__creates_as

    def group_creates_as(self):
        """
        """
        statements = self.get_statements()
        statements, creates_as = self.teradata_group_creates_as(statements=statements)

        self.set_statements(statements=statements)
        self.set_creates_as(creates_as=creates_as)

    def set_creates(self, creates):
        """
        :param creates:
        :type creates:
        """
        self.__creates = creates

    def get_creates(self):
        """
        :return:
        :rtype:
        """
        return self.__creates

    def group_creates(self):
        """
        """
        statements = self.get_statements()
        statements, creates = self.teradata_group_creates(statements=statements)

        self.set_statements(statements=statements)
        self.set_creates(creates=creates)

    def set_insert_intos(self, insert_intos):
        """
        :param insert_intos:
        :type insert_intos:
        """
        self.__insert_intos = insert_intos

    def get_insert_intos(self):
        """
        :return:
        :rtype:
        """
        return self.__insert_intos

    def group_insert_intos(self):
        """
        """
        statements = self.get_statements()
        statements, insert_intos = self.teradata_group_insert_intos(statements=statements)

        self.set_statements(statements=statements)
        self.set_insert_intos(insert_intos=insert_intos)

    def set_deletes(self, deletes):
        """
        :param deletes:
        :type:
        """
        self.__deletes = deletes

    def get_deletes(self):
        """
        :return:
        :rtype:
        """
        return self.__deletes

    def group_deletes(self):
        """
        :return:
        :rtype:
        """
        statements = self.get_statements()
        statements, deletes = self.teradata_group_deletes(statements=statements)

        self.set_statements(statements=statements)
        self.set_deletes(deletes=deletes)

    def set_updates(self, updates):
        """
        :param updates:
        :type:
        """
        self.__updates = updates

    def get_updates(self):
        """
        :return:
        :rtype:
        """
        return self.__updates

    def group_updates(self):
        """
        """
        statements = self.get_statements()
        statements, updates = self.teradata_group_updates(statements=statements)

        self.set_statements(statements=statements)
        self.set_updates(updates=updates)

    def set_create_views(self, create_views):
        self.__create_views = create_views

    def get_create_views(self):
        return self.__create_views

    def group_create_views(self):

        statements = self.get_statements()
        statements, create_views = self.teradata_group_create_views(statements=statements)

        self.set_statements(statements=statements)
        self.set_create_views(create_views=create_views)

    def set_replace_views(self, replace_views):
        self.__replace_views = replace_views

    def get_replace_views(self):
        return self.__replace_views

    def group_replace_views(self):

        statements = self.get_statements()
        statements, replace_views = self.teradata_group_replace_views(statements=statements)

        self.set_statements(statements=statements)
        self.set_replace_views(replace_views=replace_views)

    def set_create_replace_views(self, create_replace_views):
        self.__create_replace_views = create_replace_views

    def get_create_replace_views(self):
        return self.__create_replace_views

    def group_create_replace_views(self):

        statements = self.get_statements()
        statements, create_replace_views = self.teradata_group_create_replace_views(statements=statements)

        self.set_statements(statements=statements)
        self.set_create_replace_views(create_replace_views=create_replace_views)

    def group(self):
        """
        """
        self.group_creates_as()
        self.group_creates()
        self.group_insert_intos()
        self.group_deletes()
        self.group_updates()
        self.group_create_views()
        self.group_replace_views()
        self.group_create_replace_views()

