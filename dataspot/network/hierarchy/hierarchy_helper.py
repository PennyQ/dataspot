from copy import deepcopy


class HierarchyHelper:

    @staticmethod
    def list_y_levels(levels, force):
        y_levels = dict()

        for level in levels:
            for node in levels[level]:
                y_levels[node] = level

        if force != 0:
            for key, value in y_levels.items():
                y_levels[key] = abs(value)
        max_value = 0
        for level in y_levels.values():
            if level > max_value:
                max_value = level
        return y_levels

    @staticmethod
    def list_levels(levels_dict):
        levels_present = list()
        for level in levels_dict:
            levels_present.append(level)

        return levels_present

    @staticmethod
    def calc_y_coordinates(levels, y_levels, y_range, force):
        print(100, levels)
        y_level_coordinates = dict()
        y_distance = HierarchyHelper.calc_distance(range=y_range)
        y_gap = HierarchyHelper.calc_gap(distance=y_distance, levels=levels)

        if force == 0:
            for level in levels:
                y_level_coordinates[level] = min(y_range) + (y_gap * level)
        else:
            for level in levels:
                y_level_coordinates[level] = max(y_range) - (y_gap * level)

        coordinates = dict()
        for level in y_levels:
            coordinates[level] = list()

        for level, coordinate in y_level_coordinates.items():
            for node, y_level in y_levels.items():
                if level == y_level:
                    coordinates[node].append(coordinate)

        return coordinates

    @staticmethod
    def calc_x_coordinates(x_range, levels, x_levels, coordinates):
        x_distance = HierarchyHelper.calc_distance(range=x_range)

        for level in levels:
            count = 0
            x_gap = HierarchyHelper.calc_gap(distance=x_distance, levels=levels)

            for x_level, nodes in x_levels.items():
                if x_level == level:
                    new_x_range = HierarchyHelper.calc_xrange(x_gap=x_gap, nodes=nodes)
                    x_start = min(new_x_range)
                    for node in nodes:
                        x_value = x_start + (x_gap * count)
                        coordinates[node].insert(0, x_value)
                        count += 1

        return coordinates

    @staticmethod
    def list_x_levels(levels, y_levels):
        x_levels = dict()
        for level in levels:
            x_levels[level] = list()

        for level in x_levels:
            for node, y_level in y_levels.items():
                if y_level == level:
                    x_levels[level].append(node)

        return x_levels

    @staticmethod
    def calc_distance(range):
        distance = abs(range[0] - range[1])
        return distance

    @staticmethod
    def calc_gap(distance, levels):

        if max(levels) == 0:
            gap = 0
        else:
            gap = distance / max(levels)

        return gap

    @staticmethod
    def calc_xrange(x_gap, nodes):
        new_x_range = list()
        x_total = x_gap * len(nodes)
        x_min = 0 - (x_total/2)
        x_max = 0 + (x_total/2)
        new_x_range.insert(0, x_min)
        new_x_range.insert(1, x_max)

        return new_x_range

    @staticmethod
    def adjust_count_usage(count, node, y_levels, relationships):

        if node in relationships:
            for value in relationships[node]:
                if value in y_levels:
                    if y_levels[value] == count:
                        count += 1
                        return count
                    elif y_levels[value] > count:
                        count = y_levels[value] + 1
                        return count

        return count

    @staticmethod
    def adjust_count_root(count, node, y_levels, relationships):

        if node in relationships:
            for value in relationships[node]:
                if value in y_levels:
                    if y_levels[value] == count:
                        count -= 1
                        return count
                    elif y_levels[value] < count:
                        count = y_levels[value] - 1
                        return count

        return count

    @staticmethod
    def get_y_levels_old(root_list, relationships, force):
        y_levels = dict()
        start_level = 0

        root_relationships = deepcopy(relationships)

        for root_node in root_list:
            y_levels[root_node] = start_level

        for root_node in root_list:
            cur_key = [root_node]
            cur_start_level = [0]

            HierarchyHelper.list_y_levels_old(cur_key=cur_key, cur_start_level=cur_start_level,
                                          relationships=root_relationships,
                                          y_levels=y_levels, force=force)

        if force != 0:
            for key, value in y_levels.items():
                y_levels[key] = abs(value)
        max_value = 0
        for level in y_levels.values():
            if level > max_value:
                max_value = level
        return y_levels

    @staticmethod
    def list_y_levels_old(cur_key, cur_start_level, relationships, y_levels, force):

        if len(relationships[cur_key[0]]) > 0:
            for child_node in relationships[cur_key[0]]:
                if force == 0:
                    count = cur_start_level[0] + 1
                    if y_levels[cur_key[0]] == count:
                        count += 1

                    count = HierarchyHelper.adjust_count_usage(count=count, node= child_node,
                                                               relationships=relationships,
                                                               y_levels=y_levels)
                else:
                    count = cur_start_level[0]
                    if y_levels[cur_key[0]] == count:
                        count -= 1

                    count = HierarchyHelper.adjust_count_root(count=count, node=child_node,
                                                              relationships=relationships,
                                                              y_levels=y_levels)
                if child_node in y_levels:
                    if count > y_levels[child_node]:
                        y_levels[child_node] = count
                else:
                    y_levels[child_node] = count

                if child_node in relationships:
                    relationships[cur_key[0]].remove(child_node)
                    cur_key.insert(0, child_node)
                    cur_start_level.insert(0, count)
                    HierarchyHelper.list_y_levels_old(cur_key=cur_key, cur_start_level=cur_start_level,
                                                  relationships=relationships, y_levels=y_levels, force=force)
                else:
                    relationships[cur_key[0]].remove(child_node)
                    HierarchyHelper.list_y_levels_old(cur_key=cur_key, cur_start_level=cur_start_level,
                                                  relationships=relationships, y_levels=y_levels, force=force)
        else:
            cur_key.pop(0)
            cur_start_level.pop(0)
            if len(cur_key) == 0:
                return y_levels
            else:
                HierarchyHelper.list_y_levels_old(cur_key=cur_key, cur_start_level=cur_start_level,
                                              relationships=relationships, y_levels=y_levels, force=force)

    @staticmethod
    def list_roots_old(relationships):
        values_list = list()
        for values in relationships.values():
            for value in values:
                values_list.append(value)

        root_list = list()
        for key in relationships:
            if key not in values_list:
                root_list.append(key)

        return root_list

    @staticmethod
    def list_levels_old(levels_dict):
        levels = list()
        inv_map = {v: k for k, v in levels_dict.items()}
        for key in inv_map:
            if key not in levels:
                levels.append(key)
        levels.sort()

        return levels



