import abc


class StatementGrouper(metaclass=abc.ABCMeta):
    """
    StatementGrouper groups statements belonging to the same type of DML/DDL in the same list. This is done via two
    steps:

        1. Iterate over list of statements and call the respective validate function
        2. If the statements contains the DML/DDL statement the validate function will return True, otherwise False

    When the validate function returns True, the statement will be added to statement list for that type. If False,
    the statement will be added to a new list of statements. These statements thus need to be checked on their type
    of DML/DDL.
    """

    @abc.abstractmethod
    def set_statements(self, statements):
        pass

    @abc.abstractmethod
    def get_statements(self):
        pass

    @staticmethod
    def validate_create_as(statement):
        """

        :param statement:
        :return:
        """
        if statement.lower().find('create table') != -1 and statement.lower().find(' as ') != -1 and statement.lower().find(' from ') != -1:
            return True
        else:
            return False

    @staticmethod
    def teradata_group_creates_as(statements):
        """
        EXPLANATION
        :param statements:
        :return:
        """
        creates_as = list()
        new_statements = list()
        for statement in statements:
            result = StatementGrouper.validate_create_as(statement=statement)
            if result:
                creates_as.append(statement)
            else:
                new_statements.append(statement)

        return new_statements, creates_as

    @staticmethod
    def validate_create(statement):
        """
        EXPLANATION

        :param statement:
        :return:
        """
        if statement.lower().find('create table') != -1 and statement.lower().find(' as ') == -1:
            return True
        else:
            return False

    @staticmethod
    def teradata_group_creates(statements):
        """
        EXPLANATION

        :param statements:
        :return:
        """
        creates = list()
        new_statements = list()
        for statement in statements:
            result = StatementGrouper.validate_create(statement=statement)
            if result:
                creates.append(statement)
            else:
                new_statements.append(statement)

        return new_statements, creates

    @staticmethod
    def validate_insert_into(statement):
        """
        EXPLANATION

        :param statement:
        :return:
        """
        if statement.lower().find('insert into ') != -1 and statement.lower().find('select ') != -1 and \
                statement.lower().find('from') != -1:
            return True
        else:
            return False

    @staticmethod
    def teradata_group_insert_intos(statements):
        """
        EXPLANATION

        :param statements:
        :return:
        """
        insert_intos = list()
        new_statements = list()
        for statement in statements:
            result = StatementGrouper.validate_insert_into(statement=statement)
            if result:
                insert_intos.append(statement)
            else:
                new_statements.append(statement)

        return new_statements, insert_intos

    @staticmethod
    def validate_delete(statement):
        """
        EXPLANATION

        :param statement:
        :return:
        """
        if statement.lower().find('delete') != -1:
            return True
        else:
            return False

    @staticmethod
    def teradata_group_deletes(statements):
        """
        EXPLANATION

        :param statements:
        :return:
        """
        deletes = list()
        new_statements = list()
        for statement in statements:
            result = StatementGrouper.validate_delete(statement=statement)
            if result:
                deletes.append(statement)
            else:
                new_statements.append(statement)

        return new_statements, deletes

    @staticmethod
    def validate_update(statement):
        """
        EXPLANATION

        :param statement:
        :return:
        """
        if statement.lower().find('update ') != -1:
            return True
        else:
            return False

    @staticmethod
    def teradata_group_updates(statements):
        """
        EXPLANATION

        :param statements:
        :return:
        """
        updates = list()
        new_statements = list()
        for statement in statements:
            result = StatementGrouper.validate_update(statement=statement)
            if result:
                updates.append(statement)
            else:
                new_statements.append(statement)

        return new_statements, updates

    @abc.abstractmethod
    def group(self):
        pass
