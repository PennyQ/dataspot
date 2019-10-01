from dataspot.network.node_calculator import NodeCalculator


class NodeSizesNetworker:

    def __init__(self):
        self.__node_sizes = None

    def set_node(self, nodes, relationships, node_size_config, grouped_weights, levels):
        node_sizes = list()
        root_scores = NodeCalculator.calculate_root_scores(relationships=relationships, grouped_weights=grouped_weights,
                                                           levels=levels)
        for node in nodes:
            found = 0
            test = list()
            size = 0
            if node in root_scores:
                size = root_scores[node]

            for node_size, node_config in node_size_config.items():
                test.append(node_config[0])
                test.append(node_config[1])
                if node_config[0] <= int(size) < node_config[1]:
                    found_node_size = node_size
                    node_sizes.append(found_node_size)
                    found = 1

            if found == 0:
                found_node_size = max(test)
                node_sizes.append(found_node_size)

        self.__node_sizes = node_sizes

    def get_node(self):
        return self.__node_sizes

    def build(self, nodes, relationships, node_size_config, grouped_weights, levels):
        self.set_node(nodes=nodes, relationships=relationships, grouped_weights=grouped_weights,
                      node_size_config=node_size_config, levels=levels)
