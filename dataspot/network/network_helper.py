

class NetworkHelper:

    @staticmethod
    def list_nodes(graph):
        nodes = list()
        for i in graph.nodes:
            nodes.append(i.strip())

        nodes = list(set(nodes))
        return nodes
