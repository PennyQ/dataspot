

class ObjectSourceHelper:

    @staticmethod
    def validate_source(source):
        if source and source.find('(') == -1:
            return True
        else:
            return False

    @staticmethod
    def clean_statement(statement):
        statement = statement.replace('both from', '')
        statement = statement.replace('day from', '')
        statement = statement.replace('month from', '')
        statement = statement.replace('year from', '')
        return statement

    @staticmethod
    def clean_source(source):
        source = source.replace(')', '')
        return source

    @staticmethod
    def adjust_statement(source, source_result, find_key, statement):
        if source_result:
            statement = statement[statement.find(source) + len(source):len(statement)]
            source = ObjectSourceHelper.clean_source(source=source)
            return source, statement
        else:
            source = None
            statement = statement[statement.find(find_key) + len(find_key):len(statement)]
            return source, statement

    @staticmethod
    def create_source_statement(statement):
        source_statement = None
        statement = ObjectSourceHelper.clean_statement(statement=statement)
        if statement.find('from') != -1:
            source_statement = statement[statement.find('from'): len(statement)]
            return source_statement
        return source_statement
