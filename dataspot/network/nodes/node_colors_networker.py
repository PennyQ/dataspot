from dataspot.network.node_networker import NodeNetworker


class NodeColorsNetworker(NodeNetworker):

    def __init__(self):
        self.__node_colors = None

    def set_node(self, nodes, grouped_nodes, grouped_colors):
        node_colors = list()
        nodes_done = list()

        for node in nodes:
            for group, group_node in grouped_nodes.items():
                for group_name, group_color in grouped_colors.items():
                    if group == group_name:
                        if node in group_node:
                            node_colors.append(group_color)
                            nodes_done.append(node)

        self.__node_colors = node_colors

    def get_node(self):
        return self.__node_colors

    def build(self, nodes, grouped_nodes, grouped_colors):
        self.set_node(nodes=nodes, grouped_nodes=grouped_nodes, grouped_colors=grouped_colors)
