from dataspot.network.node_networker import NodeNetworker


class NodeLabelsNetworker(NodeNetworker):

    def __init__(self):
        self.__node_labels = None

    def set_node(self, nodes, grouped_nodes, grouped_legend):
        node_labels = list()

        for node in nodes:
            legend = False
            for group, tables in grouped_nodes.items():
                for group_name, group_label in grouped_legend.items():
                    if group == group_name:
                        if node in tables:
                            legend = True
                            node_labels.append(group_label)

            if not legend:
                node_labels.append('unknown')

        self.__node_labels = node_labels

    def get_node(self):
        return self.__node_labels

    def build(self, nodes, grouped_nodes, grouped_legend):
        self.set_node(nodes=nodes, grouped_nodes=grouped_nodes, grouped_legend=grouped_legend)
