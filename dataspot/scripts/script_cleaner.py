import abc


class ScriptCleaner(metaclass=abc.ABCMeta):
    """
    ScriptCleaner is meant for getting rid of all unwanted (single-line & multi-line) comments and self-defined
    statements.

    ScriptCleaner takes lines, defined as a string type, with each single line appended into a list. Furthermore,
    ScriptCleaner also allows you to pass a self defined list of lists containing statements that should be excluded
    from the script. The format for this is as follows:

    excluded_statements = [[beginning_of_statement_1, ending_of_statement_1], ...]

    Lastly, ScriptCleaner gets rid of unnecessary empty lines by just putting one empty line between statements.
    """

    @abc.abstractmethod
    def get_comment_mapping(self):
        pass

    @staticmethod
    def teradata_clean_single_line_comments(single_line_comment, lines):
        """
        Search for single-line comments in a line. When found, the line is reassigned by the values up to the
        start of the comment. For example:

        line = "I am not a comment -- I am a comment"

        Will become:

        line = "I am not a comment"

        :param single_line_comment: The value for the single line comment in the script's language
        :type List
        :param lines: A list of lines, with each line being defined as a string type
        :type List
        :return: A list of lines, with each line being defined as a string type
        :type List
        """

        new_lines = list()
        for line in lines:
            if line.find(single_line_comment) != -1:
                line = line[0:line.find(single_line_comment)]
                new_lines.append(line)
            else:
                new_lines.append(line)
        return new_lines

    @staticmethod
    def teradata_clean_multi_line_statements(multi_line_statement, lines):
        """
        Searches for multi-line statement in a single-line, or over a span of lines. When found, the line is reassigned by
        the values up to the start of the multi-line statement. For example, take a multi-line comment:

        line = "I am not a comment /* I am a comment
                I amd still a comment
                I am also a comment */ But I am not a comment anymore"

        Will become:

        line = "I am not a comment But I am not a comment anymore"

        The function will first start looking for a multi-line statement in the same line. If the closing statement is
        not found in the same line, status will be set to 1.

        With status set to 1, all lines up to the point the closing statement is found will be excluded. When the
        closing statement is found, status will be set to 0 again.

        Multi-line statements are of the following format:

        multi-line = [start_multi_line, end_multi_line]

        :param multi_line_statement: A list containing the value of the start of the statement at place 0, and the value
                                     of the end of the statement at place 1
        :type multi_line_statement: List
        :param lines: A list of lines, with each line being defined as a string type
        :type lines: List
        :return: A list of lines, with each line being defined as a string type
        """

        status = 0
        new_lines = list()
        new_line = ""
        for line in lines:
            if line.find(multi_line_statement[0]) != -1 and line.find(multi_line_statement[1]) != -1:
                line = line[: line.find(multi_line_statement[0])]
                new_lines.append(line)
            elif line.find(multi_line_statement[0]) != -1 and line.find(multi_line_statement[1]) == -1:
                status = 1
                new_line += line
            elif status == 1 and line.find(multi_line_statement[1]) == -1:
                new_line += line
            elif line.find(multi_line_statement[1]) != -1 and status == 1:
                new_line += line
                new_line_start = new_line[: new_line.find(multi_line_statement[0])]
                new_line_end = new_line[new_line.find(multi_line_statement[1]) + 2:len(new_line)]
                line = new_line_start + new_line_end
                new_line = ""
                new_lines.append(line)
                status = 0
            else:
                new_lines.append(line)
        return new_lines

    @staticmethod
    def teradata_clean_empty_lines(lines):
        """
        Takes away all unnecessary empty lines, with leaving just one empty line between statements.

        :param lines: A list of lines, with each line being defined as a string type
        :type lines: List
        :return: A list of lines, with each line being defined as a string type
        """
        status = 0
        new_lines = list()
        for line in lines:
            if (len(line) == 0 or (len(line) == 1 and line.find('') == 0)) and status == 0:
                new_lines.append(line)
                status = 1
            elif (len(line) == 0 or (len(line) == 1 and line.find('') == 0)) and status == 1:
                pass
            else:
                new_lines.append(line)
                status = 0
        return new_lines

    @staticmethod
    def teradata_replace_new_lines(lines):
        new_lines = list()
        for line in lines:
            line = line.replace('\n', ' ')
            line = line.replace('\t', ' ')
            line = line.rstrip('\n')
            new_lines.append(line)
        return new_lines

    @staticmethod
    def teradata_clean_statements(statements):
        """
        :param statements:
        :return:
        """
        new_statements = list()
        for statement in statements:
            if statement.find(' sel ') != -1:
                statement = statement.replace(' sel ', ' select ')
            if statement.find('as(') != -1:
                statement = statement.replace('as(', ' as (')
            new_statements.append(statement)
        return new_statements

    @abc.abstractmethod
    def clean(self, lines, statements=None):
        pass

# new_lines = ""
# for line in lines:
#     new_lines += line
# return new_lines


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
# new_lines = ScriptCleaner(comment_mapping=comment_mapping).clean(lines=lines, statements=statements)
# print(99, new_lines)

# pprint(new_lines)