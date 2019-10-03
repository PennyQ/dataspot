from dataspot.network.node_calculator import NodeCalculator


class NodeScoresNetworker():

    def __init__(self):
        self.__node_root_scores = None
        self.__node_usage_scores = None

    def set_node_root_scores(self, nodes, levels, relationships, grouped_weights):
        node_root_scores = list()

        root_scores = NodeCalculator.calculate_root_scores(relationships=relationships, grouped_weights=grouped_weights,
                                                           levels=levels)
        for node in nodes:
            if node in root_scores:
                node_root_score = root_scores[node]
                node_root_scores.append(node_root_score)
            else:
                node_root_scores.append(0)

        self.__node_root_scores = node_root_scores

    def get_node_root_scores(self):
        return self.__node_root_scores

    def set_node_usage_scores(self, nodes, relationships):
        node_root_scores = list()
        for node in nodes:
            score = NodeCalculator.calculate_usage_score(node=node, relationships=relationships)

            node_root_scores.append(score)

        self.__node_usage_scores = node_root_scores

    def get_node_usage_scores(self):
        return self.__node_usage_scores

    def build(self, nodes, relationships, grouped_weights, levels):
        self.set_node_root_scores(relationships=relationships, grouped_weights=grouped_weights, levels=levels,
                                  nodes=nodes)
        self.set_node_usage_scores(nodes=nodes, relationships=relationships)
