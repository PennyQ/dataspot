

class QueryParser:
    def __init__(self):
        self.__creates = None

    def set_length(self, parser):
        self.__length = len(parser) - 1

    @staticmethod
    def check_status(length, count):
        if count <= length:
            return 0
        else:
            return 1

    @staticmethod
    def check_line(line, status, start_key, end_key):
        if start_key in line and status == 0:
            status = 1
        elif end_key in line and status == 1:
            status = 2
        return status

    def parse_creates(self, parser, lines):
        creates = list()
        status = 0

        create_query = ""
        for line in lines:
            status = self.check_line(line=line, status=status, start_key=parser[0], end_key=parser[1])




