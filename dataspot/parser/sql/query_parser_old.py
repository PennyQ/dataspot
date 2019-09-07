

class QueryParser:

    def __init__(self, lines):
        self.__length = None
        self.__lines = lines
        self.__count = 0
        self.__query_found = 0
        self.__query = ""
        self.__items = list()
        self.__start_found = 0
        self.__end_found = 0

    def set_length(self, parser):
        self.__length = len(parser[0]) - 1

    def find_items(self, parser):
        # As long as not all items from the first list have been found, we stay in the first part of the if/else
        # statement
        if self.__count <= self.__length:
            # For the 'create table ... as' statement we want to find the statement 'create table' on the first line,
            # and the 'as' statement either on the first line as well, or on the next line. If neither of that is the
            # case, we state that the current statement is not a 'create table ... as' statement. In that case, we
            # reset the configurations
            if self.__count == 0 and self.__lines[0].lower().find(parser[0][self.__count]) != -1:
                self.__query += self.__lines[0].lower()
                self.__count += 1
                self.__lines.pop(0)
                self.__start_found = 1
                # If we have not yet found the second item in the current query, we need to check if it is in the
                # next line
                if self.__count == 1 and self.__start_found == 1 and self.__query.find(parser[0][self.__count]) == -1:
                    # If the second item is in the next line then we know that we have the type of statement we are
                    # after in this parser_old.
                    if self.__lines[0].lower().find(parser[0][self.__count]) != -1:
                        self.__query += self.__lines[0].lower()
                        self.__count += 1
                        self.__lines.pop(0)
                    # If the second item is not in the parser_old then we don't have a "create table ... as" statement.
                    # In that case, we need to reset our configurations
                    else:
                        self.__query = ""
                        self.__count = 0
                        self.__end_found = 0
                        self.__start_found = 0
                        self.__lines.pop(0)
                # In the case, we already have the second item in our query, we can continue parsing the rest. We only
                # need to up the count in that case
                elif self.__count == 1 and self.__start_found == 1 and self.__query.find(parser[0][self.__count]) != -1:
                    self.__count += 1
                return self.__query
            # The below statements are extra. In case, we want to check for extra arguments, without specific rules,
            # we can use the statements below.
            elif self.__lines[0].lower().find(parser[0][self.__count]) == -1 and self.__start_found == 1:
                self.__query += self.__lines[0].lower()
                self.__lines.pop(0)
                # In case we find the closing statement without having found all of the items in our first list, we need
                # to exit this query, since it does not fit our definitions.
                if self.__query.find(parser[1][0]) != -1:
                    self.__query = ""
                    self.__count = 0
                    self.__end_found = 0
                    self.__start_found = 0
                    self.__lines.pop(0)
                    return self.__query
            # If we have found the argument, we move on to the next argument.
            elif self.__lines[0].lower().find(parser[0][self.__count]) != -1 and self.__start_found == 1:
                self.__query += self.__lines[0].lower()
                self.__lines.pop(0)
                self.__count += 1
                return self.__query
            # This statement is to make sure we will not end up in an infinite loop.
            else:
                self.__lines.pop(0)
                return self.__query
        # When we have found all of the items in the list, we want to find the closing item of the query.
        elif self.__count > self.__length:
            # First we check if we have already found the closing item.
            if self.__query.find(parser[1][0]) != -1:
                self.__end_found = 1
                return self.__query
            # Then we check if the closing statement is in the current line.
            elif self.__lines[0].lower().find(parser[1][0]) != -1:
                self.__query += self.__lines[0].lower()
                self.__lines.pop(0)
                self.__end_found = 1
                return self.__query
            # If all is not the case, we continue with the lines until we have found the closing item.
            else:
                self.__query += self.__lines[0].lower()
                self.__lines.pop(0)
                return self.__query
        # This statement is to make sure we will not end up in an infinite loop.
        else:
            self.__lines.pop(0)
            return self.__query

    def set_items(self, parser):
        # As longs as we have lines to go through, we continue looping. Since the logic in the above stated function
        # makes sure that all lines will get popped, we don't have to worry about an infinite loop.
        while len(self.__lines) > 0:
            query = self.find_items(parser=parser)
            # When the closing item of a query has been found, we need to append the query to the list, and reset our
            # configurations so we can find the other statements
            if self.__end_found == 1:
                self.__items.append(query)
                self.__query = ""
                self.__count = 0
                self.__end_found = 0
                self.__start_found = 0

    def execute(self, parser):
        self.set_length(parser=parser)
        self.set_items(parser=parser)
        return self.__items
