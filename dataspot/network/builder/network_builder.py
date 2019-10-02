from dataspot.config.builder.network_configurator_builder import NetworkConfiguratorBuilder
from dataspot.config.builder.nodes_configurator_builder import NodesConfiguratorBuilder
from dataspot.network.builder.node_network_builder import NodeNetworkBuilder
from dataspot.network.network_helper import NetworkHelper
from dataspot.network.graph.graph_networker import GraphNetworker
from dataspot.network.node_calculator import NodeCalculator


class NetworkBuilder:

    def __init__(self, config, relationships):
        self.__config = config
        self.__relationships = relationships
        self.__graph = None
        self.__nodes = None
        self.__nodes_configurator_builder = None
        self.__grouped_colors = None
        self.__grouped_weights = None
        self.__grouped_legend = None
        self.__grouped_nodes = None

        self.__network_configurator_builder = None
        self.__plot_width = None
        self.__plot_height = None
        self.__x_range = None
        self.__y_range = None
        self.__golden_sources = None
        self.__levels = None

        self.__node_network_builder = None
        self.__node_size_config = None
        self.__node_colors = None
        self.__node_sizes = None
        self.__node_labels = None
        self.__node_root_scores = None
        self.__node_usage_scores = None

        self.__graph_renderer = None
        self.__axis = None
        self.__network = None

    def set_config(self, config):
        self.__config = config

    def get_config(self):
        return self.__config

    def set_relationships(self, relationships):
        self.__relationships = relationships

    def get_relationships(self):
        return self.__relationships

    def set_graph(self):
        relationships = self.get_relationships()
        self.__graph = GraphNetworker.build_graph(relationships=relationships)

    def get_graph(self):
        return self.__graph

    def set_nodes(self):
        graph = self.get_graph()
        nodes = NetworkHelper.list_nodes(graph=graph)


        self.__nodes = nodes

    def get_nodes(self):
        return self.__nodes

    def set_nodes_configurator_builder(self):
        config = self.get_config()
        relationships = self.get_relationships()
        nodes_configurator_builder = NodesConfiguratorBuilder(config=config, relationships=relationships)
        nodes_configurator_builder.build()
        self.__nodes_configurator_builder = nodes_configurator_builder

    def get_nodes_configurator_builder(self):
        return self.__nodes_configurator_builder

    def set_grouped_colors(self):
        nodes_configurator_builder = self.get_nodes_configurator_builder()
        self.__grouped_colors = nodes_configurator_builder.get_grouped_colors()

    def get_grouped_colors(self):
        return self.__grouped_colors

    def set_grouped_weights(self):
        nodes_configurator_builder = self.get_nodes_configurator_builder()
        self.__grouped_weights = nodes_configurator_builder.get_grouped_weights()

    def get_grouped_weights(self):
        return self.__grouped_weights

    def set_grouped_legend(self):
        nodes_configurator_builder = self.get_nodes_configurator_builder()
        self.__grouped_legend = nodes_configurator_builder.get_grouped_legend()

    def get_grouped_legend(self):
        return self.__grouped_legend

    def set_grouped_nodes(self):
        nodes_configurator_builder = self.get_nodes_configurator_builder()
        self.__grouped_nodes = nodes_configurator_builder.get_grouped_nodes()

    def get_grouped_nodes(self):
        return self.__grouped_nodes

    def set_network_configurator_builder(self):
        config = self.get_config()
        network_configurator_builder = NetworkConfiguratorBuilder(config=config)
        network_configurator_builder.build()
        self.__network_configurator_builder = network_configurator_builder

    def get_network_configurator_builder(self):
        return self.__network_configurator_builder

    def set_node_size_config(self):
        network_configurator_builder = self.get_network_configurator_builder()
        self.__node_size_config = network_configurator_builder.get_node_size_config()

    def get_node_size_config(self):
        return self.__node_size_config

    def set_plot_width(self):
        network_configurator_builder = self.get_network_configurator_builder()
        self.__plot_width = network_configurator_builder.get_plot_width()

    def get_plot_width(self):
        return self.__plot_width

    def set_plot_height(self):
        network_configurator_builder = self.get_network_configurator_builder()
        self.__plot_height = network_configurator_builder.get_plot_height()

    def get_plot_height(self):
        return self.__plot_height

    def set_x_range(self):
        network_configurator_builder = self.get_network_configurator_builder()
        self.__x_range = network_configurator_builder.get_x_range()

    def get_x_range(self):
        return self.__x_range

    def set_y_range(self):
        network_configurator_builder = self.get_network_configurator_builder()
        self.__y_range = network_configurator_builder.get_y_range()

    def get_y_range(self):
        return self.__y_range

    def set_golden_sources(self):
        network_configurator_builder = self.get_network_configurator_builder()
        self.__golden_sources = network_configurator_builder.get_golden_sources()

    def get_golden_sources(self):
        return self.__golden_sources

    def set_levels(self):
        relationships = self.get_relationships()
        nodes = self.get_nodes()
        golden_sources = self.get_golden_sources()
        levels = NodeCalculator.calculate_levels(relationships=relationships, nodes=nodes,
                                                 golden_sources=golden_sources)
        self.__levels = levels

    def get_levels(self):
        return self.__levels

    def set_node_network_builder(self):
        nodes = self.get_nodes()
        relationships = self.get_relationships()
        node_size_config = self.get_node_size_config()
        grouped_nodes = self.get_grouped_nodes()
        grouped_colors = self.get_grouped_colors()
        grouped_weights = self.get_grouped_weights()
        grouped_legend = self.get_grouped_legend()
        levels = self.get_levels()

        node_network_builder = NodeNetworkBuilder()
        node_network_builder.build(nodes=nodes, relationships=relationships, node_size_config=node_size_config,
                                   grouped_nodes=grouped_nodes, grouped_colors=grouped_colors,
                                   grouped_weights=grouped_weights, grouped_legend=grouped_legend, levels=levels)
        self.__node_network_builder = node_network_builder

    def get_node_network_builder(self):
        return self.__node_network_builder

    def set_node_colors(self):
        node_network_builder = self.get_node_network_builder()
        self.__node_colors = node_network_builder.get_node_colors()

    def get_node_colors(self):
        return self.__node_colors

    def set_node_sizes(self):
        node_network_builder = self.get_node_network_builder()
        self.__node_sizes = node_network_builder.get_node_sizes()

    def get_node_sizes(self):
        return self.__node_sizes

    def set_node_labels(self):
        node_network_builder = self.get_node_network_builder()
        self.__node_labels = node_network_builder.get_node_labels()

    def get_node_labels(self):
        return self.__node_labels

    def set_node_scores(self):
        node_network_builder = self.get_node_network_builder()
        self.__node_root_scores = node_network_builder.get_node_root_scores()
        self.__node_usage_scores = node_network_builder.get_node_usage_scores()

    def get_node_root_scores(self):
        return self.__node_root_scores

    def get_node_usage_scores(self):
        return self.__node_usage_scores

    def set_graph_renderer(self):
        graph = self.get_graph()
        nodes = self.get_nodes()
        node_colors = self.get_node_colors()
        node_labels = self.get_node_labels()
        node_sizes = self.get_node_sizes()
        node_scores = [self.get_node_root_scores(), self.get_node_usage_scores()]
        levels = self.get_levels()

        self.__graph_renderer = GraphNetworker.build_graph_renderer(graph=graph, nodes=nodes, node_colors=node_colors,
                                                                    node_labels=node_labels, node_sizes=node_sizes,
                                                                    node_scores=node_scores, levels=levels)

    def get_graph_renderer(self):
        return self.__graph_renderer

    def set_axis(self):
        x_range = self.get_x_range()
        y_range = self.get_y_range()
        nodes = self.get_nodes()
        levels = self.get_levels()
        self.__axis = GraphNetworker.build_axis(x_range=x_range, y_range=y_range, nodes=nodes, levels=levels)

    def get_axis(self):
        return self.__axis

    def set_lay_out(self):
        graph_renderer = self.get_graph_renderer()
        axis = self.get_axis()
        self.__graph_renderer = GraphNetworker.build_lay_out(graph_renderer=graph_renderer, axis=axis)

    def manual_set_lay_out(self, graph_renderer, axis):
        self.__graph_renderer = GraphNetworker.build_lay_out(graph_renderer=graph_renderer, axis=axis)

    def set_network(self):
        graph_renderer = self.get_graph_renderer()
        plot_width = self.get_plot_width()
        plot_height = self.get_plot_height()
        x_range = self.get_x_range()
        y_range = self.get_y_range()
        grouped_colors = self.get_grouped_colors()
        grouped_legend = self.get_grouped_legend()
        self.__network = GraphNetworker.build_network(graph_renderer=graph_renderer, plot_width=plot_width,
                                                      plot_height=plot_height, x_range=x_range, y_range=y_range,
                                                      grouped_colors=grouped_colors, grouped_legend=grouped_legend)

    def get_network(self):
        return self.__network

    def build(self):
        self.set_graph()
        self.set_nodes()

        self.set_nodes_configurator_builder()
        self.set_grouped_colors()
        self.set_grouped_weights()
        self.set_grouped_legend()
        self.set_grouped_nodes()

        self.set_network_configurator_builder()
        self.set_node_size_config()
        self.set_golden_sources()
        self.set_x_range()
        self.set_y_range()
        self.set_plot_width()
        self.set_plot_height()

        self.set_levels()

        self.set_node_network_builder()
        self.set_node_colors()
        self.set_node_sizes()
        self.set_node_labels()
        self.set_node_scores()

        self.set_graph_renderer()
        self.set_axis()

        self.set_lay_out()
        self.set_network()
