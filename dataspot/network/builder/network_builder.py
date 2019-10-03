from dataspot.config.builder.network_configurator_builder import NetworkConfiguratorBuilder
from dataspot.config.builder.nodes_configurator_builder import NodesConfiguratorBuilder
from dataspot.network.builder.node_network_builder import NodeNetworkBuilder
from dataspot.network.nodes.node_list_networker import NodeListNetworker
from dataspot.network.graph.graph_networker import GraphNetworker


from dataspot.network.node_calculator import NodeCalculator

class NetworkBuilder:

    def __init__(self):
        self.__config = None
        self.__relationships = None
        self.__graph = None
        self.__grouped_colors = None
        self.__grouped_weights = None
        self.__grouped_legend = None
        self.__grouped_nodes = None
        self.__node_size_config = None
        self.__nodes = None
        self.__node_colors = None
        self.__node_sizes = None
        self.__node_labels = None
        self.__node_root_scores = None
        self.__node_usage_scores = None
        self.__plot_width = None
        self.__plot_height = None
        self.__x_range = None
        self.__y_range = None
        self.__golden_sources = None
        self.__graph_renderer = None
        self.__axis = None
        self.__network = None
        self.__levels = None

    def set_config(self, config):
        self.__config = config

    def get_config(self):
        return self.__config

    def set_relationships(self, relationships):
        self.__relationships = relationships

    def get_relationships(self):
        return self.__relationships

    def set_graph(self, relationships):
        graph_networker = GraphNetworker()
        self.__graph = graph_networker.build_graph(relationships=relationships)

    def get_graph(self):
        return self.__graph

    def set_nodes(self, graph):
        node_list_networker = NodeListNetworker()
        node_list_networker.build(graph=graph)
        self.__nodes = node_list_networker.get_node()

    def get_nodes(self):
        return self.__nodes

    def set_grouped_colors(self, nodes_configurator_builder):
        self.__grouped_colors = nodes_configurator_builder.get_grouped_colors()

    def get_grouped_colors(self):
        return self.__grouped_colors

    def set_grouped_weights(self, nodes_configurator_builder):
        self.__grouped_weights = nodes_configurator_builder.get_grouped_weights()

    def get_grouped_weights(self):
        return self.__grouped_weights

    def set_grouped_legend(self, nodes_configurator_builder):
        self.__grouped_legend = nodes_configurator_builder.get_grouped_legend()

    def get_grouped_legend(self):
        return self.__grouped_legend

    def set_grouped_nodes(self, nodes_configurator_builder):
        self.__grouped_nodes = nodes_configurator_builder.get_grouped_nodes()

    def get_grouped_nodes(self):
        return self.__grouped_nodes

    def set_node_size_config(self, network_configurator_builder):
        self.__node_size_config = network_configurator_builder.get_node_size_config()

    def get_node_size_config(self):
        return self.__node_size_config

    def set_node_colors(self, node_network_builder):
        self.__node_colors = node_network_builder.get_node_colors()

    def get_node_colors(self):
        return self.__node_colors

    def set_node_sizes(self, node_network_builder):
        self.__node_sizes = node_network_builder.get_node_sizes()

    def get_node_sizes(self):
        return self.__node_sizes

    def set_node_labels(self, node_network_builder):
        self.__node_labels = node_network_builder.get_node_labels()

    def get_node_labels(self):
        return self.__node_labels

    def set_node_scores(self, node_network_builder):
        self.__node_root_scores = node_network_builder.get_node_root_scores()
        self.__node_usage_scores = node_network_builder.get_node_usage_scores()

    def get_node_root_scores(self):
        return self.__node_root_scores

    def get_node_usage_scores(self):
        return self.__node_usage_scores

    def set_plot_width(self, network_configurator_builder):
        self.__plot_width = network_configurator_builder.get_plot_width()

    def get_plot_width(self):
        return self.__plot_width

    def set_plot_height(self, network_configurator_builder):
        self.__plot_height = network_configurator_builder.get_plot_height()

    def get_plot_height(self):
        return self.__plot_height

    def set_x_range(self, network_configurator_builder):
        self.__x_range = network_configurator_builder.get_x_range()

    def get_x_range(self):
        return self.__x_range

    def set_y_range(self, network_configurator_builder):
        self.__y_range = network_configurator_builder.get_y_range()

    def get_y_range(self):
        return self.__y_range

    def set_golden_sources(self, network_configurator_builder):
        self.__golden_sources = network_configurator_builder.get_golden_sources()

    def get_golden_sources(self):
        return self.__golden_sources

    def set_graph_renderer(self, graph, nodes, node_colors, node_labels, node_sizes, node_scores):
        graph_networker = GraphNetworker()
        self.__graph_renderer = graph_networker.build_graph_renderer(graph=graph, nodes=nodes, node_colors=node_colors,
                                                                     node_labels=node_labels, node_sizes=node_sizes,
                                                                     node_scores=node_scores)

    def get_graph_renderer(self):
        return self.__graph_renderer

    def set_axis(self, x_range, y_range, nodes, levels, force):
        graph_networker = GraphNetworker()
        self.__axis = graph_networker.build_axis(x_range=x_range, y_range=y_range, nodes=nodes, levels=levels,
                                                 force=force)

    def get_axis(self):
        return self.__axis

    def set_lay_out(self, graph_renderer, axis):
        graph_networker = GraphNetworker()
        self.__graph_renderer = graph_networker.build_lay_out(graph_renderer=graph_renderer, axis=axis)

    def set_network(self, graph_renderer, plot_width, plot_height, x_range, y_range, grouped_colors,
                    grouped_legend):
        graph_networker = GraphNetworker()
        self.__network = graph_networker.build_network(graph_renderer=graph_renderer, plot_width=plot_width,
                                                       plot_height=plot_height, x_range=x_range, y_range=y_range,
                                                       grouped_colors=grouped_colors,
                                                       grouped_legend=grouped_legend)

    def get_network(self):
        return self.__network

    def set_levels(self, relationships, nodes, golden_sources):
        levels = NodeCalculator.calculate_levels(relationships=relationships, nodes=nodes,
                                                 golden_sources=golden_sources)
        self.__levels = levels

    def get_levels(self):
        return self.__levels

    def build(self, config, relationships, force):
        self.set_relationships(relationships = relationships)
        self.set_config(config=config)
        self.set_graph(relationships=relationships)
        self.set_nodes(graph=self.get_graph())

        nodes_configurator_builder = NodesConfiguratorBuilder(config=config, relationships=relationships)
        nodes_configurator_builder.build()
        self.set_grouped_colors(nodes_configurator_builder=nodes_configurator_builder)
        self.set_grouped_weights(nodes_configurator_builder=nodes_configurator_builder)
        self.set_grouped_legend(nodes_configurator_builder=nodes_configurator_builder)
        self.set_grouped_nodes(nodes_configurator_builder=nodes_configurator_builder)

        network_configurator_builder = NetworkConfiguratorBuilder(config=config)
        network_configurator_builder.build()
        self.set_node_size_config(network_configurator_builder=network_configurator_builder)
        self.set_golden_sources(network_configurator_builder=network_configurator_builder)
        self.set_levels(golden_sources=self.get_golden_sources(), nodes=self.get_nodes(), relationships=relationships)
        self.set_x_range(network_configurator_builder=network_configurator_builder)
        self.set_y_range(network_configurator_builder=network_configurator_builder)

        node_network_builder = NodeNetworkBuilder()
        node_network_builder.build(relationships=relationships,
                                   grouped_colors=self.get_grouped_colors(), grouped_weights=self.get_grouped_weights(),
                                   grouped_legend=self.get_grouped_legend(), grouped_nodes=self.get_grouped_nodes(),
                                   node_size_config=self.get_node_size_config(), nodes=self.get_nodes(),
                                   levels=self.get_levels())
        self.set_node_colors(node_network_builder=node_network_builder)
        self.set_node_sizes(node_network_builder=node_network_builder)
        self.set_node_labels(node_network_builder=node_network_builder)
        self.set_node_scores(node_network_builder=node_network_builder)

        # Graph Networker
        self.set_graph_renderer(graph=self.get_graph(), nodes=self.get_nodes(), node_colors=self.get_node_colors(),
                                node_sizes=self.get_node_sizes(), node_labels=self.get_node_labels(),
                                node_scores=[self.get_node_root_scores(), self.get_node_usage_scores()])
        self.set_axis(x_range=self.get_x_range(), y_range=self.get_y_range(), nodes=self.get_nodes(),
                      levels=self.get_levels(), force=force)
        self.set_lay_out(graph_renderer=self.get_graph_renderer(), axis=self.get_axis())

        self.set_plot_width(network_configurator_builder=network_configurator_builder)
        self.set_plot_height(network_configurator_builder=network_configurator_builder)

        self.set_network(graph_renderer=self.get_graph_renderer(), plot_width=self.get_plot_width(),
                         plot_height=self.get_plot_height(), x_range=self.get_x_range(), y_range=self.get_y_range(),
                         grouped_colors=self.get_grouped_colors(), grouped_legend=self.get_grouped_legend())
