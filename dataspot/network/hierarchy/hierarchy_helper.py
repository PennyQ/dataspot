from copy import deepcopy


class HierarchyHelper:

    @staticmethod
    def list_y_levels(levels):
        y_levels = dict()

        for level in levels:
            for node in levels[level]:
                y_levels[node] = level

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
    def calc_y_coordinates(levels, y_levels, y_range):
        y_level_coordinates = dict()
        y_distance = HierarchyHelper.calc_distance(range=y_range)
        y_gap = HierarchyHelper.calc_gap(distance=y_distance, levels=levels)

        for level in levels:
            y_level_coordinates[level] = min(y_range) + (y_gap * level)

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

        cur_x_start = 0
        for level in levels:
            count = 0
            x_gap = HierarchyHelper.calc_gap(distance=x_distance, levels=levels)

            for x_level, nodes in x_levels.items():
                if x_level == level:
                    new_x_range = HierarchyHelper.calc_xrange(x_gap=x_gap, nodes=nodes)
                    x_start = min(new_x_range)
                    if x_start == cur_x_start:
                        x_start += x_gap
                    else:
                        cur_x_start = x_start

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



