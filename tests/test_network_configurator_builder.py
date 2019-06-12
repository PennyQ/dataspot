import unittest
import json
from dataspot.config.network.node_size_configurator import NodeSizeConfigurator
from dataspot.config.network.yrange_configurator import YRangeConfigurator
from dataspot.config.network.xrange_configurator import XRangeConfigurator
from dataspot.config.network.plot_height_configurator import PlotHeightConfigurator
from dataspot.config.network.plot_width_configurator import PlotWidthConfigurator
from dataspot.config.builder.network_configurator_builder import NetworkConfiguratorBuilder


class TestNetworkConfiguratorBuilder(unittest.TestCase):

    def setUp(self):
        self.__config_path = '/Users/patrickdehoon/PycharmProjects/Dataspot/tests/config_old/dataspot_config.json'
        self.__plot_width = 880
        self.__plot_height = 880
        self.__x_range = (-1.5, 1.5)
        self.__y_range = (-1.5, 1.5)
        self.__node_size_config = {"10": [0, 10], "15": [10, 20], "20": [20, 30], "25": [30, 40], "30": [40, 50],
                                   "35": [50, 60], "40": [50, 70], "45": [70, 80], "50": [80, 90], "55": [90, 100]}

    def test_plot_width(self):
        config_path = self.__config_path
        f = open(config_path)
        config = json.load(f)
        f.close()

        plot_width_configurator = PlotWidthConfigurator()
        plot_width_configurator.build(config=config)
        result = plot_width_configurator.get_config()

        self.assertEqual(self.__plot_width, result)

    def test_plot_height(self):
        config_path = self.__config_path
        f = open(config_path)
        config = json.load(f)
        f.close()

        plot_height_configurator = PlotHeightConfigurator()
        plot_height_configurator.build(config=config)
        result = plot_height_configurator.get_config()

        self.assertEqual(self.__plot_height, result)

    def test_x_range(self):
        config_path = self.__config_path
        f = open(config_path)
        config = json.load(f)
        f.close()

        x_range_configurator = XRangeConfigurator()
        x_range_configurator.build(config=config)
        result = x_range_configurator.get_config()

        self.assertEqual(self.__x_range, result)

    def test_y_range(self):
        config_path = self.__config_path
        f = open(config_path)
        config = json.load(f)
        f.close()

        y_range_configurator = YRangeConfigurator()
        y_range_configurator.build(config=config)
        result = y_range_configurator.get_config()

        self.assertEqual(self.__y_range, result)

    def test_node_size_config(self):
        config_path = self.__config_path
        f = open(config_path)
        config = json.load(f)
        f.close()

        node_size_configurator = NodeSizeConfigurator()
        node_size_configurator.build(config=config)
        result = node_size_configurator.get_config()

        self.assertEqual(self.__node_size_config, result)

    def test_builder(self):
        config_path = self.__config_path
        f = open(config_path)
        config = json.load(f)
        f.close()

        network_config_builder = NetworkConfiguratorBuilder()
        network_config_builder.build(config=config)

        self.assertEqual(self.__plot_height, network_config_builder.get_plot_height())
        self.assertEqual(self.__plot_width, network_config_builder.get_plot_width())
        self.assertEqual(self.__x_range, network_config_builder.get_x_range())
        self.assertEqual(self.__y_range, network_config_builder.get_y_range())
        self.assertEqual(self.__node_size_config, network_config_builder.get_node_size_config())

    def tearDown(self):
        pass


if __name__ == '__main__':
    unittest.main()
