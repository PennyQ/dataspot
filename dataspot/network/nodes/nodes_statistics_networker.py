from dataspot.network.node_calculator import NodeCalculator
from dataspot.network.node_networker import NodeNetworker


class NodeStatisticsNetworker(NodeNetworker):

    def __init__(self):
        self.__node_statistics = None

    def set_node(self, nodes, config, statistic):
        node_statistics = list()

        for node in nodes:
            if node in config['statistics'][statistic]:
                node_statistics.append(config['statistics'][statistic][node])
            else:
                node_statistics.append("-101")

        self.__node_statistics = node_statistics

    def get_node(self):
        return self.__node_statistics

    def build(self, nodes, config, statistic):
        self.set_node(nodes=nodes, config=config, statistic=statistic)
