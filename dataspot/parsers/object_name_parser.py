

class ObjectNameParser:

    @staticmethod
    def teradata_parse_object_name(statement, start_key, end_key):
        object_name = None

        if statement.find(start_key) != -1:
            # print(1, statement)
            object_name = statement[statement.find(start_key) + len(start_key):statement.find(end_key)].strip()
            # print(2, object_name)
            if object_name == "":
                print(3, 'hey')
            return object_name

        return object_name

    @staticmethod
    def teradata_parse_object_names(statements, start_key, end_key):

        object_names = list()
        for statement in statements:
            object_name = ObjectNameParser.teradata_parse_object_name(statement=statement, start_key=start_key,
                                                                      end_key=end_key)
            object_names.append(object_name)

        return object_names
