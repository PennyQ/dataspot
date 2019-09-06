import re


class StatementSeparator:

    """
    StatementSeparator pulls apart all of the statements in a script and returns a list containing separated statement.
    """

    @staticmethod
    def separate(lines, statement_end):
        """
        Starts scanning for an alphabetic character in a line. When found status is set to one, and lines are being
        added to 'new_object'. When the end of the statement is found, status is set to 0 and the object is appended to
        'script_object'. As long as no alphabetic character is found, lines will be skipped from this point.

        :param lines: A list of lines, with each line being defined as a string type
        :type List
        :param statement_end: Value that signals the end of statements
        :type String
        :return: A list containing separated statements
        :type List
        """
        script_objects = list()
        status = 0
        new_object = ""
        for line in lines:
            if re.search('[a-zA-Z]', line) and status == 0:
                new_object += line
                status = 1
            elif status == 1 and line.find(statement_end) == -1:
                new_object += line
            elif status == 1 and line.find(statement_end) != -1:
                new_object += line
                status = 0
                script_objects.append(new_object)
                new_object = ""
            else:
                pass
        return script_objects
