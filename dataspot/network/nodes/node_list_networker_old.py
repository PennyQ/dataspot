from dataspot.network.node_networker import NodeNetworker


class NodeListNetworker(NodeNetworker):

    def __init__(self):
        self.__nodes = None

    def set_node(self, graph):
        nodes = list()
        for i in graph.nodes:
            nodes.append(i.strip())

        nodes = list(set(nodes))
        self.__nodes = nodes

    def get_node(self):
        return self.__nodes

    def build(self, graph):
        self.set_node(graph=graph)
