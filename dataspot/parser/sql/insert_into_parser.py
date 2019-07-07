

class InsertIntoParser:

    def __init__(self, lines):
        self._length = None
        self._lines = lines
        self._count = 0
        self._query_found = 0
        self._query = ""
        self._inserts = list()
        self._start_found = 0
        self._end_found = 0

    def set_length(self, parser):
        self._length = len(parser['insert'][0]) - 1

    def find_inserts(self, parser):
        # As long as not all items from the first list have been found, we stay in the first part of the if/else
        # statement
        if self._count <= self._length:
            # For the 'create table ... as' statement we want to find the statement 'create table' on the first line,
            # and the 'as' statement either on the first line as well, or on the next line. If neither of that is the
            # case, we state that the current statement is not a 'create table ... as' statement. In that case, we
            # reset the configurations
            if self._count == 0 and self._lines[0].lower().find(parser['insert'][0][self._count]) != -1:
                self._query += self._lines[0].lower()
                self._count += 1
                self._lines.pop(0)
                self._start_found = 1
                # If we have not yet found the second item in the current query, we need to check if it is in the
                # next line
                if self._count == 1 and self._start_found == 1 and self._query.find(
                        parser['insert'][0][self._count]) == -1:
                    # If the second item is in the next line then we know that we have the type of statement we are
                    # after in this parser.
                    if self._lines[0].lower().find(parser['insert'][0][self._count]) != -1:
                        self._query += self._lines[0].lower()
                        self._count += 1
                        self._lines.pop(0)
                    # If the second item is not in the parser then we don't have a "create table ... as" statement.
                    # In that case, we need to reset our configurations
                    else:
                        self._query = ""
                        self._count = 0
                        self._end_found = 0
                        self._start_found = 0
                        self._lines.pop(0)
                # In the case, we already have the second item in our query, we can continue parsing the rest. We only
                # need to up the count in that case
                elif self._count == 1 and self._start_found == 1 and self._query.find(
                        parser['insert'][0][self._count]) != -1:
                    self._count += 1
                return self._query
            # The below statements are extra. In case, we want to check for extra arguments, without specific rules,
            # we can use the statements below.
            elif self._lines[0].lower().find(parser['insert'][0][self._count]) == -1 and self._start_found == 1:
                self._query += self._lines[0].lower()
                self._lines.pop(0)
                # In case we find the closing statement without having found all of the items in our first list, we need
                # to exit this query, since it does not fit our definitions.
                if self._query.find(parser['insert'][1][0]) != -1:
                    self._query = ""
                    self._count = 0
                    self._end_found = 0
                    self._start_found = 0
                    self._lines.pop(0)
                    return self._query
            # If we have found the argument, we move on to the next argument.
            elif self._lines[0].lower().find(parser['insert'][0][self._count]) != -1 and self._start_found == 1:
                self._query += self._lines[0].lower()
                self._lines.pop(0)
                self._count += 1
                return self._query
            # This statement is to make sure we will not end up in an infinite loop.
            else:
                self._lines.pop(0)
                return self._query
        # When we have found all of the items in the list, we want to find the closing item of the query.
        elif self._count > self._length:
            # First we check if we have already found the closing item.
            if self._query.find(parser['insert'][1][0]) != -1:
                self._end_found = 1
                return self._query
            # Then we check if the closing statement is in the current line.
            elif self._lines[0].lower().find(parser['insert'][1][0]) != -1:
                self._query += self._lines[0].lower()
                self._lines.pop(0)
                self._end_found = 1
                return self._query
            # If all is not the case, we continue with the lines until we have found the closing item.
            else:
                self._query += self._lines[0].lower()
                self._lines.pop(0)
                return self._query
        # This statement is to make sure we will not end up in an infinite loop.
        else:
            self._lines.pop(0)
            return self._query

    def set_inserts(self, parser):
        # As longs as we have lines to go through, we continue looping. Since the logic in the above stated function
        # makes sure that all lines will get popped, we don't have to worry about an infinite loop.
        while len(self._lines) > 0:
            query = self.find_inserts(parser=parser)
            # When the closing item of a query has been found, we need to append the query to the list, and reset our
            # configurations so we can find the other statements
            if self._end_found == 1:
                self._inserts.append(query)
                self._query = ""
                self._count = 0
                self._end_found = 0
                self._start_found = 0

    def execute(self, parser):
        self.set_length(parser=parser)
        self.set_inserts(parser=parser)
        return self._inserts
