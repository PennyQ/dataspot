from dataspot.network.node_calculator import NodeCalculator


class NodeScoresNetworker():

    def __init__(self):
        self.__node_root_scores = None
        self.__node_usage_scores = None

    def set_node_root_scores(self, nodes, relationships, grouped_weights):
        node_root_scores = list()
        for node in nodes:

            score = NodeCalculator.calculate_root_score(node=node, relationships=relationships,
                                                        grouped_weights=grouped_weights)

            node_root_scores.append(score)

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

    def build(self, nodes, relationships, grouped_weights):
        self.set_node_root_scores(nodes=nodes, relationships=relationships, grouped_weights=grouped_weights)
        self.set_node_usage_scores(nodes=nodes, relationships=relationships)
