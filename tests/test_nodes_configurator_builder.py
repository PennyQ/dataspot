import json
import unittest
from dataspot.config.nodes.colors_configurator import ColorsConfigurator
from dataspot.config.nodes.legend_configurator import LegendConfigurator
from dataspot.config.nodes.weights_configurator import WeightsConfigurator
from dataspot.config.nodes.nodes_configurator import NodesConfigurator
from dataspot.config.builder.nodes_configurator_builder import NodesConfiguratorBuilder


class TestNodesConfiguratorBuilder(unittest.TestCase):

    def setUp(self):
        self.__config_path = '/Users/patrickdehoon/PycharmProjects/Dataspot/tests/config_old/dataspot_config.json'
        self.__script_path = '/Users/patrickdehoon/PycharmProjects/Dataspot/tests/dataspot_invalid_script_test.sql'
        self.__relationships = {"general.test3": ["general.test1"], "general.test2": ["general.test1"]}
        self.__grouped_colors = {'general': '#006480'}
        self.__grouped_legend = {'general': 'general'}
        self.__grouped_weights = {1: ['general.test1', 'general.test2', 'general.test3']}
        self.__grouped_nodes = {"general": ["general.test1", "general.test2", "general.test3"]}

    def test_colors(self):
        config_path = self.__config_path
        f = open(config_path)
        config = json.load(f)
        f.close()

        colors_configurator = ColorsConfigurator()
        colors_configurator.build(config=config)
        result = colors_configurator.get_config()

        self.assertEqual(self.__grouped_colors, result)

    def test_legend(self):
        config_path = self.__config_path
        f = open(config_path)
        config = json.load(f)
        f.close()

        legend_configurator = LegendConfigurator()
        legend_configurator.build(config=config)
        result = legend_configurator.get_config()

        self.assertEqual(self.__grouped_legend, result)

    def test_weights(self):
        config_path = self.__config_path
        f = open(config_path)
        config = json.load(f)
        f.close()

        weights_configurator = WeightsConfigurator()
        weights_configurator.build(config=config, grouped_nodes=self.__grouped_nodes)
        result = weights_configurator.get_config()

        self.assertEqual(self.__grouped_weights, result)

    def test_nodes(self):
        config_path = self.__config_path
        f = open(config_path)
        config = json.load(f)
        f.close()

        nodes_configurator = NodesConfigurator()
        nodes_configurator.build(config=config, relationships=self.__relationships)
        result = nodes_configurator.get_config()
        for key, value in result.items():
            value.sort()

        self.assertEqual(self.__grouped_nodes, result)

    def test_builder(self):
        config_path = self.__config_path
        f = open(config_path)
        config = json.load(f)
        f.close()

        nodes_config_builder = NodesConfiguratorBuilder()
        nodes_config_builder.build(config=config, relationships=self.__relationships)

        grouped_nodes = nodes_config_builder.get_grouped_nodes()
        for key, value in grouped_nodes.items():
            value.sort()
        self.assertEqual(self.__grouped_nodes, grouped_nodes)

        grouped_weights = nodes_config_builder.get_grouped_weights()
        for key, value in grouped_weights.items():
            value.sort()
        self.assertEqual(self.__grouped_weights, nodes_config_builder.get_grouped_weights())
        self.assertEqual(self.__grouped_legend, nodes_config_builder.get_grouped_legend())
        self.assertEqual(self.__grouped_colors, nodes_config_builder.get_grouped_colors())

    def tearDown(self):
        pass


if __name__ == '__main__':
    unittest.main()
