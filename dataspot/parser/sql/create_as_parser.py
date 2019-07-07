

class CreateAsParser:
    def __init__(self, lines):
        self.end = None
        self.lines = lines
        self.count = 0
        self.query_found = 0
        self.query = ""
        self.creates = list()
        self.start_found = 0
        self.end_found = 0

    def set_end(self, parser):
        self.end = len(parser['create'][0]) - 1

    def find_creates(self, parser):
        # As long as not all items from the first list have been found, we stay in the first part of the if/else
        # statement
        if self.count <= self.end:
            # For the 'create table ... as' statement we want to find the statement 'create table' on the first line,
            # and the 'as' statement either on the first line as well, or on the next line. If neither of that is the
            # case, we state that the current statement is not a 'create table ... as' statement. In that case, we
            # reset the configurations
            if self.count == 0 and self.lines[0].lower().find(parser['create'][0][self.count]) != -1:
                self.query += self.lines[0].lower()
                self.count += 1
                self.lines.pop(0)
                self.start_found = 1
                if self.count == 1 and self.start_found == 1 and self.query.find(parser['create'][0][self.count]) == -1:
                    if self.lines[0].lower().find(parser['create'][0][self.count]) != -1:
                        self.query += self.lines[0].lower()
                        self.count += 1
                        self.lines.pop(0)
                    else:
                        self.query = ""
                        self.count = 0
                        self.end_found = 0
                        self.start_found = 0
                        self.lines.pop(0)
                elif self.count == 1 and self.start_found == 1 and self.query.find(parser['create'][0][self.count]) != -1:
                    self.count += 1
                return self.query
            elif self.lines[0].lower().find(parser['create'][0][self.count]) == -1 and self.start_found == 1:
                self.query += self.lines[0].lower()
                self.lines.pop(0)
                return self.query
            else:
                self.lines.pop(0)
                return self.query
        elif self.count > self.end:
            if self.query.find(parser['create'][1][0]) != -1:
                self.end_found = 1
                return self.query
            elif self.lines[0].lower().find(parser['create'][1][0]) != -1:
                self.query += self.lines[0].lower()
                self.lines.pop(0)
                self.end_found = 1
                return self.query
            else:
                self.query += self.lines[0].lower()
                self.lines.pop(0)
                return self.query
        else:
            return self.query

    def set_creates(self, parser):
        while len(self.lines) > 0:
            query = self.find_creates(parser=parser)
            if self.end_found == 1:
                self.creates.append(query)
                self.query = ""
                self.count = 0
                self.end_found = 0
                self.start_found = 0

    def execute(self, parser):
        self.set_end(parser=parser)
        self.set_creates(parser=parser)
        return self.creates
