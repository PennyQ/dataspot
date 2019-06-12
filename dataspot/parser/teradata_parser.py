import re


class TeradataParser:

    def __init__(self):
        pass

    @staticmethod
    def list_creates(script):
        creates = list()
        query_found = 0
        query = ""

        with open(script, 'r') as f:
            f = f.readlines()
            for i in f:
                if i.lower().find('create table') != -1 and query_found == 0:
                    query_found = 1
                    query += i
                elif query_found == 1 and i.lower().find(';') != -1:
                    query += i
                    if query.lower().find('with data') != -1:
                        creates.append(query)
                        query = ""
                        query_found = 0
                    else:
                        query = ""
                        query_found = 0
                elif query_found == 1:
                    query += i
                else:
                    pass

        return creates

    @staticmethod
    def list_inserts(script):
        inserts = list()
        query_found = 0
        query = ""

        with open(script, 'r') as f:
            f = f.readlines()
            for i in f:
                if i.lower().find('insert into') != -1 and query_found == 0:
                    query_found = 1
                    query += i
                elif query_found == 1 and i.lower().find(';') != -1 and i.lower().find('both') == -1:
                    query += i
                    inserts.append(query)
                    query_found = 0
                    query = ""
                elif query_found == 1:
                    query += i
                else:
                    pass

        return inserts

    @staticmethod
    def list_views(script):
        views = list()
        query_found = 0
        query = ""

        with open(script, 'r') as f:
            f = f.readlines()
            for i in f:
                if (i.lower().find('replace view') != -1 or i.lower().find('create view') != -1) and query_found == 0:
                    query_found = 1
                    query += i
                elif query_found == 1 and i.lower().find(';') == -1:
                    query += i
                elif query_found == 1 and i.lower().find(';') != -1:
                    query += i
                    views.append(query)
                    query_found = 0
                    query = ""
                else:
                    pass

        return views

    @staticmethod
    def list_queries(inserts, creates, views):
        queries = inserts + creates + views

        return queries

    @staticmethod
    def list_table_name(query):
        query = query.lower()
        if query.find('insert into') != -1 and query.find('values') != -1 and query.find('select') == -1:
            table_key = query[query.find("insert into") + 12:query.find("values")]
            option = 'insert into'
            table_key = table_key.strip()
            return table_key, option
        elif query.find('insert into') != -1 and query.find('sel') != -1:
            option = 'insert into'
            table_key = query[query.find("insert into") + 12:query.find("sel")]
            table_key = table_key.strip()
            return table_key, option
        elif query.find('create table') != -1:
            option = 'create table'
            if query.find("as\n") != -1:
                table_key = query[query.find("create table") + 13:query.find("as\n")]
                table_key = table_key.strip()
                return table_key, option
            elif query.find(" as ") != -1:
                table_key = query[query.find("create table") + 13:query.find(" as")]
                table_key = table_key.strip()
                return table_key, option
            elif query.find(" as") != -1:
                table_key = query[query.find("create table") + 13:query.find(" as")]
                table_key = table_key.strip()
                return table_key, option
            elif query.find("as ") != -1:
                table_key = query[query.find("create table") + 13:query.find("as")]
                table_key = table_key.strip()
                return table_key, option
        elif query.find('create view') != -1:
            option = 'create view'
            if query.find("as\n") != -1:
                table_key = query[query.find("create view") + 12:query.find("as\n")]
                table_key = table_key.strip()
                return table_key, option
            elif query.find(" as ") != -1:
                table_key = query[query.find("create table") + 12:query.find(" as")]
                table_key = table_key.strip()
                return table_key, option
        elif query.find('replace view') != -1:
            option = 'replace view'
            if query.find("as\n") != -1:
                table_key = query[query.find("replace view") + 13:query.find("as\n")]
                table_key = table_key.strip()
                return table_key, option
            elif query.find(" as ") != -1:
                table_key = query[query.find("replace view") + 13:query.find(" as")]
                table_key = table_key.strip()
                return table_key, option
            elif query.find("as ") != -1:
                table_key = query[query.find("replace view") + 13:query.find("as ")]
                table_key = table_key.strip()
                return table_key, option

    @staticmethod
    def list_table_keys_and_options(queries):
        table_keys = list()
        options = list()
        for query in queries:
            table_key, option = TeradataParser.list_table_name(query=query)
            table_keys.append(table_key)
            options.append(option)

        return table_keys, options

    @staticmethod
    def list_relationships(queries, table_keys, options):
        count = len(table_keys)
        status = 0
        relationships = dict()

        while status < count:
            try:
                from_statement = TeradataParser.list_from_statement(query=queries[status],
                                                                    table_name=table_keys[status],
                                                                    option=options[status])

                adjusted_from_statement = from_statement
                adjustable_from_statement = str()
                sources = list()
                source = str()
                froms_or_joins = 0
                deepest_level_ind = 0
                table_sources = TeradataParser.list_table_sources(from_statement=from_statement,
                                                                  adjusted_from_statement=adjusted_from_statement,
                                                                  adjustable_from_statement=adjustable_from_statement,
                                                                  sources=sources, source=source, froms_or_joins=
                                                                  froms_or_joins,deepest_level_ind=deepest_level_ind)

                table_sources = list(dict.fromkeys(table_sources))
                relationships[table_keys[status]] = table_sources
                status += 1

            except RecursionError:
                import sys
                import traceback
                code, message, backtrace = sys.exc_info()
                format_backtrace = "".join(traceback.format_exception(code, message, backtrace))
                print(format_backtrace)
                print(table_keys[status])

        return relationships

    @staticmethod
    def list_table_sources(from_statement, adjusted_from_statement, adjustable_from_statement, sources, source,
                           froms_or_joins, deepest_level_ind):
        # Step 1: Find all sub-selects via 'from'
        if froms_or_joins == 0:
            # Step 1.1: In the original query we are going to select everything
            # after the first 'from' until the end of the original query
            if deepest_level_ind == 0:
                # This is logical, of course we are going to find a 'from' => error needed if not?
                if adjusted_from_statement.find('from') != -1:
                    # We are trying to capture the value at the deepest level first.
                    # Hence, we try to exhaust all 'from' statements from the original query first
                    source = adjusted_from_statement[adjusted_from_statement.find("from") + 5:
                                                     len(adjusted_from_statement)]

                    # Now we are curious... Can we still find a 'from' in the value?
                    # If so, we need to dig deeper (flag_2 = 1).
                    # If not, we are done and we can append the value to our list (flag_2 = 2)
                    if source.find('from') != -1:
                        deepest_level_ind = 1

                    else:
                        deepest_level_ind = 2

                    TeradataParser.list_table_sources(from_statement, adjusted_from_statement, adjustable_from_statement
                                                      , sources, source, froms_or_joins, deepest_level_ind)

            elif deepest_level_ind == 1:
                # Since we know that we are going to find a 'from', we are going to remove everything up
                # and till this 'from'

                source = source[source.find("from") + 5:len(source)]

                # Now that we have cut off the 'from', we are curious... can we still find another from?
                # If not we are done (flag_2 = 2) and we can append it to our list. If not, we will continue digging!
                if source.find('from') == -1:
                    deepest_level_ind = 2

                TeradataParser.list_table_sources(from_statement, adjusted_from_statement, adjustable_from_statement,
                                                  sources,source, froms_or_joins, deepest_level_ind)

            else:
                # We have finished this level, so we need to remove the value from the original,
                # so we can move up one level in the query
                adjustable_from_statement = adjusted_from_statement[0:adjusted_from_statement.rfind(source) - 5]

                # Since we are at the end of this level, we need to capture the table's name in this value
                sources, source = TeradataParser.clean_source(sources=sources, source=source, froms_or_joins=froms_or_joins)

                # Final Step, Part 1: If all sub-selects, and the eventual main 'from' have been captured,
                # it is time to move on to the joins (flag_1 = 1), else we need to continue
                if adjustable_from_statement.find('from') != -1:
                    froms_or_joins = 0
                    deepest_level_ind = 0
                    adjusted_from_statement = adjustable_from_statement
                    adjustable_from_statement = ""
                    TeradataParser.list_table_sources(from_statement, adjusted_from_statement, adjustable_from_statement
                                                      , sources, source, froms_or_joins, deepest_level_ind)
                else:
                    froms_or_joins = 1
                    deepest_level_ind = 0
                    adjusted_from_statement = from_statement
                    TeradataParser.list_table_sources(from_statement, adjusted_from_statement, adjustable_from_statement
                                                      , sources, source, froms_or_joins, deepest_level_ind)

        elif froms_or_joins == 1:
            if deepest_level_ind == 0:
                # This is logical, of course we are going to find a 'join' => error needed if not?
                if adjusted_from_statement.find('join') != -1:

                    # We are trying to capture the value at the deepest level first.
                    # Hence, we try to exhaust all 'from' statements from the original query first
                    source = adjusted_from_statement[
                             adjusted_from_statement.find("join") + 5:len(adjusted_from_statement)]

                    # Now we are curious... Can we still find a 'from' in the value?
                    # If so, we need to dig deeper (flag_2 = 1).
                    # If not, we are done and we can append the value to our list (flag_2 = 1)
                    if source.find('join') == -1:
                        deepest_level_ind = 2

                    # If flag_2 = 1, we don't need the original query anymore. In this part we start
                    # making our way down from the value
                    else:
                        deepest_level_ind = 1

                    TeradataParser.list_table_sources(from_statement, adjusted_from_statement, adjustable_from_statement
                                                      , sources, source, froms_or_joins, deepest_level_ind)

                else:
                    froms_or_joins = 2
                    TeradataParser.list_table_sources(from_statement, adjusted_from_statement, adjustable_from_statement
                                                      , sources, source, froms_or_joins, deepest_level_ind)

            elif deepest_level_ind == 1:
                # Since we know that we are going to find a 'from', we are going to remove everything up
                # and till this 'from'
                source = source[source.find("join") + 5:len(source)]
                # Now that we have cut off the 'join', we are curious... can we still find another join?
                # If not we are done (flag_2 = 2) and we can append it to our list. If not, we will continue digging!
                if source.find('join') == -1:
                    deepest_level_ind = 2

                TeradataParser.list_table_sources(from_statement, adjusted_from_statement, adjustable_from_statement,
                                                  sources, source, froms_or_joins, deepest_level_ind)

            else:
                # We have finished this level, so we need to remove the value from the original,
                # so we can move up one level in the query
                adjustable_from_statement = adjusted_from_statement[0:adjusted_from_statement.rfind(source) - 5]

                # Since we are at the end of this level, we need to capture the table's name in this value
                sources, source = TeradataParser.clean_source(sources=sources, source=source, froms_or_joins=
                                                              froms_or_joins)

                # Final Step, Part 1: If all sub-selects, and the eventual main 'from' have been captured,
                # it is time to move on to the joins
                if adjustable_from_statement.find('join') != -1:
                    froms_or_joins = 1
                    deepest_level_ind = 0
                    adjusted_from_statement = adjustable_from_statement
                    TeradataParser.list_table_sources(from_statement, adjusted_from_statement, adjustable_from_statement
                                                      , sources, source, froms_or_joins, deepest_level_ind)
                else:
                    froms_or_joins = 2
                    adjusted_from_statement = from_statement
                    TeradataParser.list_table_sources(from_statement, adjusted_from_statement, adjustable_from_statement
                                                      , sources, source, froms_or_joins, deepest_level_ind)

        else:
            return sources
        return sources

    @staticmethod
    def clean_source(sources, source, froms_or_joins):
        if source.find('\n') != -1:
            source = source[0:source.find('\n')]
            if source.find(")") != -1:
                source = source[0:source.find(")")]
            elif source.find(";") != -1:
                source = source[0:source.find(";")]
            elif source.find(' ') != -1:
                source = source[0:source.find(" ")]
        elif source.find(';') != -1 and froms_or_joins == 0:
            source = source[0:source.find(";")]
        elif source.find(')') != -1 and froms_or_joins == 0:
            source = source[0:source.find(")")]
        elif source.find(' ') != -1 and froms_or_joins == 1:
            source = source[0:source.find(" ")]
        elif source.find(';') != -1 and froms_or_joins == 1:
            source = source[0:source.find(";")]

        if source.find('\t') != -1:
            source = source.replace('\t', ' ')
            source.strip()

        if source.find('mi_vm_ldm.aparty_naam') != -1:
            if source.find('\t'):
                print(source)

        # We have captured the value. Now we just need to save it in our list
        # Before appending we need to make sure we are taking into a table name. Since a table name cannot
        # contain a '(' or a '--' we will check for that first

        if source.find('--') == -1 and source.find('(') == -1:
            if source and source.find(' for ') == -1 and froms_or_joins == 0:
                if source.find(' ') != -1:
                    source = source[0:source.find(" ")]
                source.strip()
                if source.find('.') != -1:
                    sources.append(source)
            elif source.find('select') == -1 and froms_or_joins == 1:
                if source.find(' ') != -1:
                    source = source.replace(' ', '')
                if source and source.find('.') != -1:
                    sources.append(source)

        return sources, source

    @staticmethod
    def list_from_statement(query, table_name, option):
        query = query.lower()
        start = option + ' ' + table_name
        uncleaned_from_statement = query[query.find(start):len(query)]

        cleaned_from_statement = TeradataParser.clean_from_statement(uncleaned_from_statement)
        from_statement = cleaned_from_statement[cleaned_from_statement.find("from"):cleaned_from_statement.find(';')]
        return from_statement

    @staticmethod
    def clean_from_statement(from_statement):
        from_statement = from_statement.replace('both from', '')
        from_statement = from_statement.replace('day from', '')
        from_statement = from_statement.replace('month from', '')
        from_statement = from_statement.replace('year from', '')
        return from_statement