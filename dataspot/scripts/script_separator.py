import re
from pprint import pprint


class ScriptSeparator:

    """
    ScriptSeparator pulls apart all of the statements in a script and returns a list containing separated statement.
    """

    @staticmethod
    def separate(script, statement_end):
        """
        Starts scanning for an alphabetic character in a line. When found status is set to one, and lines are being
        added to 'new_object'. When the end of the statement is found, status is set to 0 and the object is appended to
        'script_object'. As long as no alphabetic character is found, lines will be skipped from this point.

        :param script: A list of lines, with each line being defined as a string type
        :type script: List
        :param statement_end: Value that signals the end of statements
        :type statement_end: String
        :return: A list containing separated statements
        """
        script_objects = list()
        status = 0
        new_object = ""
        for line in script:
            if re.search('[a-zA-Z]', line) and status == 0:
                new_object += line.lower()
                status = 1
            elif status == 1 and line.find(statement_end) == -1:
                new_object += line.lower()
            elif status == 1 and line.find(statement_end) != -1:
                new_object += line.lower()
                status = 0
                script_objects.append(new_object)
                new_object = ""
            else:
                pass
        return script_objects
