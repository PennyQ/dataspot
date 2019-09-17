from pprint import pprint


class NodeCalculator:

    @staticmethod
    def calculate_node_size(node, relationships):
        linked_tables = list()
        size = 0
        for table_key, table_value in relationships.items():
            if table_key == node:
                for table in relationships[table_key]:
                    linked_tables.append(table)

        if len(linked_tables) == 0:
            size = 1
            return size
        else:
            if node in linked_tables:
                linked_tables = [table for table in linked_tables if table != node]

            for table in linked_tables:
                for table_key, table_value in relationships.items():
                    if table_key == table:
                        for table in relationships[table_key]:
                            if table not in linked_tables:
                                linked_tables.append(table)
            size = size + len(linked_tables)

            return size

    @staticmethod
    def calculate_root_score(node, relationships, grouped_weights):
        score = 0
        for x, y in grouped_weights.items():
            if node in y:
                score = x
            else:
                score = 1

        linked_nodes = list()
        if node in relationships:
            for node in relationships[node]:
                linked_nodes.append(node)

        else:
            return score

        if node in linked_nodes:
            linked_nodes = [linked_node for linked_node in linked_nodes if linked_node != node]

        for node_source in linked_nodes:
            for x, y in grouped_weights.items():
                if node_source in y:
                    score += x
                else:
                    score += 1
                if node_source in relationships:
                    for node in relationships[node_source]:
                        if node not in linked_nodes:
                            linked_nodes.append(node)

        return score

    @staticmethod
    def calculate_usage_score(node, relationships):
        linked_nodes = list()
        for node_key, node_value in relationships.items():
            if node in node_value:
                linked_nodes.append(node_key)

        used_keys = list()
        for node_source in linked_nodes:
            for node_key, node_value in relationships.items():
                if node_source in node_value and node_key not in used_keys:
                    linked_nodes.append(node_key)
                    used_keys.append(node_key)

        score = len(linked_nodes)
        return score

    @staticmethod
    def calculate_root_score_level_0(nodes, root_scores, golden_sources, grouped_weights):
        return root_scores

    @staticmethod
    def calculate_root_score_level_1(nodes, root_scores, golden_sources, grouped_weights):
        return root_scores

    @staticmethod
    def calculate_root_score_level_2(nodes, root_scores, golden_sources, grouped_weights):
        return root_scores

    @staticmethod
    def calculate_root_score_remainging_levels(nodes, root_scores, golden_sources, grouped_weights):
        return root_scores

    @staticmethod
    def new_calculate_root_scores(nodes, golden_sources, relationships, grouped_weights):
        # Levels are needed to calculate the right root score. This is the case because you need to determine,
        # which direction you need to go. Golden sources have the level 0 indicator, thus only having their own
        # value as its root score.
        root_scores = dict()

        calculated_nodes = dict()
        # A golden source only has it's own weight as root score
        for source in golden_sources:
            for weight in grouped_weights.keys():
                if source in grouped_weights[weight]:
                    score = weight
                    calculated_nodes[source] = score

        to_do_nodes = nodes

        for node in calculated_nodes.keys():
            to_do_nodes.remove(node)

        for node in to_do_nodes:
            # When a node is not present as a key in relationships, it means that it is not based on another object,
            # and thus only has its own value
            if node not in relationships.keys():
                for weight in grouped_weights.keys():
                    if node in grouped_weights[weight]:
                        score = weight
                        calculated_nodes[node] = score
                        to_do_nodes.remove(node)

        return calculated_nodes

    @staticmethod
    def undouble_list(list_objects):
        list_objects = list(set(list_objects))
        return list_objects

    @staticmethod
    def check_level(levels, level):
        if len(levels[level]) > 0:
            level += 1
        return level

    @staticmethod
    def list_max_level_nodes(nodes, relationships):
        max_nodes = list()
        to_do_nodes = list()
        for node in nodes:
            present = 0
            for key in relationships.keys():
                if node in relationships[key]:
                    present = 1

            if present == 0:
                max_nodes.append(node)
            else:
                to_do_nodes.append(node)

        max_nodes = NodeCalculator.undouble_list(list_objects=max_nodes)
        to_do_nodes = NodeCalculator.undouble_list(list_objects=to_do_nodes)

        return to_do_nodes, max_nodes

    @staticmethod
    def list_level_0(level, levels, golden_sources, nodes):
        levels[level] = list()
        to_do_nodes = list()
        for node in nodes:
            if node in golden_sources:
                levels[level].append(node)
            else:
                to_do_nodes.append(node)

        to_do_nodes = NodeCalculator.undouble_list(list_objects=to_do_nodes)
        levels[level] = NodeCalculator.undouble_list(list_objects=levels[level])

        return to_do_nodes, levels

    @staticmethod
    def list_level_1(level, levels, nodes, relationships, golden_sources):
        levels[level] = list()
        to_do_nodes = list()
        for node in nodes:
            if node not in relationships and node not in golden_sources:
                levels[level].append(node)
            else:
                to_do_nodes.append(node)

        to_do_nodes = NodeCalculator.undouble_list(list_objects=to_do_nodes)
        levels[level] = NodeCalculator.undouble_list(list_objects=levels[level])
        return to_do_nodes, levels

    @staticmethod
    def list_level_2(level, levels, nodes, relationships):
        levels[level] = list()
        to_do_nodes = list()
        for node in nodes:
            present = 0
            for key in relationships.keys():
                for source in relationships[key]:
                    if source in nodes:
                        present = 1
            if present == 0:
                levels[level].append(node)
            else:
                to_do_nodes.append(node)

        to_do_nodes = NodeCalculator.undouble_list(list_objects=to_do_nodes)
        levels[level] = NodeCalculator.undouble_list(list_objects=levels[level])
        return to_do_nodes, levels

    @staticmethod
    def dict_remaining_levels(nodes, level, relationships):
        to_do_levels = dict()
        for node in nodes:
            check_level = level
            level_up_nodes = list()
            for source in relationships[node]:
                if source in nodes:
                    level_up_nodes.append(source)
            for level_up_node in level_up_nodes:
                check_level += 1
                for source in relationships[level_up_node]:
                    if source in nodes and source not in level_up_nodes:
                        level_up_nodes.append(source)

            if check_level in to_do_levels:
                to_do_levels[check_level].append(node)
            else:
                to_do_levels[check_level] = [node]

        return to_do_levels

    @staticmethod
    def combine_levels(levels, to_do_levels):
        levels = {**levels, **to_do_levels}
        return levels

    @staticmethod
    def find_max_level(levels):
        max_level = 0
        for key in levels.keys():
            if key > max_level:
                max_level = key
        max_level += 1
        return max_level

    @staticmethod
    def add_max_level(levels, level, max_nodes):
        levels[level] = max_nodes
        return levels

    @staticmethod
    def calculate_levels(golden_sources, nodes, relationships):
        levels = dict()
        level = 0

        # On level 0 only the golden sources will be placed. The golden sources are the absolute primitive of the
        # hierarchy, and should thus be placed on the absolute bottom of the hierarchy.
        nodes, levels = NodeCalculator.list_level_0(level=level, levels=levels, golden_sources=golden_sources,
                                                    nodes=nodes)

        level = NodeCalculator.check_level(levels=levels, level=level)

        # Now we first check if we can also spot the absolute root objects. An absolute root object follows these
        # conditions:
        # [*] Not a Golden Source
        # [*] Is a key in the relationships dictionary
        # [*] Is not present as a source for any of the keys in the relationships dictionary
        nodes, max_nodes = NodeCalculator.list_max_level_nodes(nodes=nodes, relationships=relationships)

        # On level 1, we will place all the object that follow these conditions:
        # [*] Not a Golden Source
        # [*] Not a key in the relationships dictionary
        nodes, levels = NodeCalculator.list_level_1(level=level, levels=levels, golden_sources=golden_sources,
                                                    nodes=nodes, relationships=relationships)

        level = NodeCalculator.check_level(levels=levels, level=level)

        # On level 2, we will place all the object that follow these conditions:
        # [*] Not a Golden Source
        # [*] Is a key in the relationships dictionary
        # [*] No connection with other objects, except for the objects in level 0 & 1
        nodes, levels = NodeCalculator.list_level_2(level=level, levels=levels, nodes=nodes,
                                                    relationships=relationships)

        level = NodeCalculator.check_level(levels=levels, level=level)

        # For the remaining levels, we take the following steps for each remaining node:
        # [1] Check for the remaining node's sources, if any of these sources are also present in the list of the
        #     remaining nodes
        # [2] If former is the case, we append this source to a checklist.
        # [3] We iterate over every node of this list and up the level's value by one.
        # [4] During this iteration, we check if this node also has any sources that is in the first list.
        # [5] If former is the case, we check if this node is not already present in the checklist. If this is not the
        #     case, we add it to the checklist
        # [6] After all the iterations have ended, we put the level as a key to a dictionary, append the node to a list
        #     of this key
        to_do_levels = NodeCalculator.dict_remaining_levels(nodes=nodes, level=level, relationships=relationships)

        levels = NodeCalculator.combine_levels(levels=levels, to_do_levels=to_do_levels)

        level = NodeCalculator.find_max_level(levels=levels)
        levels = NodeCalculator.add_max_level(levels=levels, level=level, max_nodes=max_nodes)

        """
        EXAMPLE:
        
      5                                             'test_db_1.example_table_a'  
      4                                             'test_db_1.example_table_b'
      3                                             'test_db_2.example_table_b'
      2                             'test_db_2.example_table_a', 'test_db_4.example_table_a'
      1             'test_db_3.example_table_c', 'test_db_3.example_table_b', 'test_db_2.example_table_c', 'test_db_3.example_table_a'
      0                             'golden_source.example_table_a', 'golden_source.example_table_b'
        """
        return levels
