import json
import unittest
from dataspot.network.builder.network_builder import NetworkBuilder


class TestNetworkBuilder(unittest.TestCase):

    def setUp(self):
        self.__config_path = '/Users/patrickdehoon/PycharmProjects/Dataspot/tests/config_old/dataspot_config.json'
        self.__relationships = {'general.test2': ['general.test1'], 'general.test3': ['general.test1']}

    def test_builder(self):
        relationships = self.__relationships
        config_path = self.__config_path
        f = open(config_path)
        config = json.load(f)
        f.close()
        network_builder = NetworkBuilder()
        network_builder.build(config=config, relationships=relationships)
        result_network = network_builder.get_network()
        result_graph_renderer = network_builder.get_graph_render()
        print("result_network", result_network)
        print("result_graph_renderer", result_graph_renderer)

    def tearDown(self):
        pass


if __name__ == '__main__':
    unittest.main()