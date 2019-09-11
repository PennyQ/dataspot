from dataspot.scripts.script_cleaner import ScriptCleaner


class TeradataScriptCleaner(ScriptCleaner):
    """
    Teradata implementation of ScriptCleaner.
    """

    def __init__(self, comment_mapping):
        """
        :param comment_mapping: A dictionary containing the following keys and values:
                        * single_line_comment => contains a string value identifying the start of the comment
                        * multi_line_comment => contains a list, which holds two string values identifying the
                                                start and end of the comment
        :type comment_mapping: Dictionary
        """
        self.__comment_mapping = comment_mapping

    def get_comment_mapping(self):
        return self.__comment_mapping

    def clean(self, lines, statements=None):
        """
        Cleans the script of (single & multi-line) comments and (optionally) statements, and returns the cleaned script.

        :param lines: A list of lines, with each line being defined as a string type
        :type lines: List
        :param statements: A list that holds lists with start and end identifiers of statements that needs to be
                           excluded from the script
        :type statements: List
        :return: A list of lines, with each line being defined as a string type
        """

        comment_mapping = self.get_comment_mapping()
        single_line_comment = comment_mapping['single_line_comment']
        multi_line_comment = comment_mapping['multi_line_comment']
        lines = self.teradata_clean_multi_line_statements(multi_line_statement=multi_line_comment, lines=lines)
        lines = self.teradata_clean_single_line_comments(single_line_comment=single_line_comment, lines=lines)

        if statements:
            for statement in statements:
                lines = self.teradata_clean_multi_line_statements(multi_line_statement=statement, lines=lines)
        lines = self.teradata_clean_empty_lines(lines=lines)
        lines = self.teradata_replace_new_lines(lines=lines)
        return lines
