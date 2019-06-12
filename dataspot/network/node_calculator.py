

class NodeCalculator:

    def __init__(self):
        pass

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
