import unittest
from dataspot.network.graph.graph_networker import GraphNetworker
from dataspot.network.builder.node_network_builder import NodeNetworkBuilder


class TestNodeNetworkBuilder(unittest.TestCase):

    def setUp(self):
        self.__relationships = {"general.test3": ["general.test1"], "general.test2": ["general.test1"]}
        self.__grouped_colors = {'general': '#006480'}
        self.__grouped_legend = {'general': 'general'}
        self.__grouped_weights = {1: ['general.test1', 'general.test2', 'general.test3']}
        self.__grouped_nodes = {"general": ["general.test1", "general.test2", "general.test3"]}
        self.__node_size_config = {"10": [0, 10], "15": [10, 20], "20": [20, 30], "25": [30, 40], "30": [40, 50],
                                   "35": [50, 60], "40": [50, 70], "45": [70, 80], "50": [80, 90], "55": [90, 100]}
        self.__node_sizes = ['10', '10', '10']
        self.__node_scores = [1, 1, 1]
        self.__node_colors = ['#006480', '#006480', '#006480']
        self.__node_labels = ['general', 'general', 'general']
        self.__nodes = ['general.test3', 'general.test2', 'general.test1']

    def test_builder(self):
        graph = GraphNetworker.build_graph(relationships=self.__relationships)

        node_network_builder = NodeNetworkBuilder()
        node_network_builder.build(graph=graph, relationships=self.__relationships,
                                   node_size_config=self.__node_size_config, grouped_nodes=self.__grouped_nodes,
                                   grouped_legend=self.__grouped_legend, grouped_weights=self.__grouped_weights,
                                   grouped_colors=self.__grouped_colors)

        self.assertEqual(self.__node_scores, node_network_builder.get_node_scores())
        self.assertEqual(self.__node_sizes, node_network_builder.get_node_sizes())
        self.assertEqual(self.__node_labels, node_network_builder.get_node_labels())
        self.assertEqual(self.__node_colors, node_network_builder.get_node_colors())
        self.assertEqual(self.__nodes, node_network_builder.get_nodes())

    def tearDown(self):
        pass


if __name__ == '__main__':
    unittest.main()
