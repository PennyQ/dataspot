from pprint import pprint


class ObjectNameParser:

    @staticmethod
    def parse_object_name(statement, start_key, end_key):
        object_name = None
        # pprint(statement)

        if statement.find(start_key) != -1:
            object_name = statement[statement.find(start_key) + len(start_key):statement.find(end_key)].strip()
            return object_name

        return object_name

    @staticmethod
    def parse_object_names(statements, start_key, end_key):

        object_names = list()
        for statement in statements:
            object_name = ObjectNameParser.parse_object_name(statement=statement, start_key=start_key, end_key=end_key)
            object_names.append(object_name)

        return object_names
