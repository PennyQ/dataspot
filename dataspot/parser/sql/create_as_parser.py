

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
                # If we have not yet found the second item in the current query, we need to check if it is in the
                # next line
                if self.count == 1 and self.start_found == 1 and self.query.find(parser['create'][0][self.count]) == -1:
                    # If the second item is in the next line then we know that we have the type of statement we are
                    # after in this parser.
                    if self.lines[0].lower().find(parser['create'][0][self.count]) != -1:
                        self.query += self.lines[0].lower()
                        self.count += 1
                        self.lines.pop(0)
                    # If the second item is not in the parser then we don't have a "create table ... as" statement.
                    # In that case, we need to reset our configurations
                    else:
                        self.query = ""
                        self.count = 0
                        self.end_found = 0
                        self.start_found = 0
                        self.lines.pop(0)
                # In the case, we already have the second item in our query, we can continue parsing the rest. We only
                # need to up the count in that case
                elif self.count == 1 and self.start_found == 1 and self.query.find(parser['create'][0][self.count]) != -1:
                    self.count += 1
                return self.query
            # The below statements are extra. In case, we want to check for extra arguments, without specific rules,
            # we can use the statements below.
            elif self.lines[0].lower().find(parser['create'][0][self.count]) == -1 and self.start_found == 1:
                self.query += self.lines[0].lower()
                self.lines.pop(0)
                return self.query
            else:
                self.lines.pop(0)
                return self.query
        # When we have found all of the items in the list, we want to find the closing item of the query.
        elif self.count > self.end:
            # First we check if we have already found the closing item.
            if self.query.find(parser['create'][1][0]) != -1:
                self.end_found = 1
                return self.query
            # Then we check if the closing statement is in the current line.
            elif self.lines[0].lower().find(parser['create'][1][0]) != -1:
                self.query += self.lines[0].lower()
                self.lines.pop(0)
                self.end_found = 1
                return self.query
            # If all is not the case, we continue with the lines until we have found the closing item.
            else:
                self.query += self.lines[0].lower()
                self.lines.pop(0)
                return self.query
        else:
            return self.query

    def set_creates(self, parser):
        # As longs as we have lines to go through, we continue looping. Since the logic in the above stated function
        # makes sure that all lines will get popped, we don't have to worry about an infinite loop.
        while len(self.lines) > 0:
            query = self.find_creates(parser=parser)
            # When the closing item of a query has been found, we need to append the query to the list, and reset our
            # configurations so we can find the other statements
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
