from dataspot.network.node_calculator import NodeCalculator
from dataspot.network.node_networker import NodeNetworker
import collections


class NodeSizesNetworker(NodeNetworker):

    def __init__(self):
        self.__node_sizes = None

    def set_node(self, nodes, relationships, node_size_config, grouped_weights):
        node_sizes = list()

        for node in nodes:
            found = 0
            test = list()
            size = NodeCalculator.calculate_root_score(node=node, relationships=relationships,
                                                       grouped_weights=grouped_weights)

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

    def build(self, nodes, relationships, node_size_config, grouped_weights):
        self.set_node(nodes=nodes, relationships=relationships, grouped_weights=grouped_weights,
                      node_size_config=node_size_config)
