from dataspot.parsers.object_name_parser import ObjectNameParser


class TeradataObjectNameParser:

    @staticmethod
    def parse_object_name(statement, start_key, end_key):
        object_name = ObjectNameParser.teradata_parse_object_name(statement=statement, start_key=start_key,
                                                                  end_key=end_key)
        return object_name

    @staticmethod
    def parse_object_names(statements, start_key, end_key):
        object_names = ObjectNameParser.teradata_parse_object_names(statements=statements, start_key=start_key,
                                                                    end_key=end_key)
        return object_names
