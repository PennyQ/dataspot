from dataspot.visualization.visual_helper import VisualHelper
from dataspot.relationships.relationships_helper import RelationshipHelper
from dataspot.network.builder.network_builder import NetworkBuilder


class ButtonCallback:

    def __init__(self, network_builder=None, callback_type=None):
        self.__network_builder = network_builder
        self.__callback_type = callback_type
        self.__relationships = network_builder.get_relationships()
        self.__config = network_builder.get_config()
        self.__graph_renderer = network_builder.get_graph_renderer()
        self.__nodes = network_builder.get_nodes()

    def get_network_builder(self):
        return self.__network_builder

    def get_callback_type(self):
        return self.__callback_type

    def get_relationships(self):
        return self.__relationships

    def get_config(self):
        return self.__config

    def get_graph_renderer(self):
        return self.__graph_renderer

    def get_nodes(self):
        return self.__nodes

    @staticmethod
    def get_callback_relationships(relationships, callback_nodes, input_node):

        callback_relationships = RelationshipHelper.build_relationships(callback_nodes=callback_nodes,
                                                                        relationships=relationships)

        if not callback_relationships:
            callback_relationships = dict()
            callback_relationships[input_node] = list()

        return callback_relationships

    def callback(self, attr, old, new):
        nodes = self.get_nodes()

        if new and new in nodes:
            network_builder = self.get_network_builder()
            callback_type = self.get_callback_type()
            relationships = self.get_relationships()
            config = self.get_config()
            graph_renderer = self.get_graph_renderer()

            # strip blank spaces from input. Otherwise, the functions will not find the object.
            input_node = new.strip()
            callback_nodes = VisualHelper.list_network_nodes(callback_type=callback_type, input_node=input_node,
                                                             relationships=relationships)

            # For every node in the root nodes, find all the sources of that object. The end product is a subset of
            # the original relationships dictionary of the whole analysis set
            callback_relationships = self.get_callback_relationships(relationships=relationships,
                                                                     callback_nodes=callback_nodes,
                                                                     input_node=input_node)

            new_network_builder = NetworkBuilder(relationships=callback_relationships, config=config)
            new_network_builder.build()
            new_graph_renderer = new_network_builder.get_graph_renderer()

            nodes = new_graph_renderer.node_renderer.data_source.data
            edges = new_graph_renderer.edge_renderer.data_source.data

            graph_renderer.node_renderer.data_source.data = nodes
            graph_renderer.edge_renderer.data_source.data = edges

            axis = new_network_builder.get_axis()

            network_builder.manual_set_lay_out(graph_renderer=graph_renderer, axis=axis)

        else:
            network_builder = self.get_network_builder()
            graph_renderer = self.__graph_renderer
            relationships = self.__relationships
            config = self.__config

            new_network_builder = NetworkBuilder(relationships=relationships, config=config)
            new_network_builder.build()
            new_graph_renderer = new_network_builder.get_graph_renderer()

            nodes = new_graph_renderer.node_renderer.data_source.data
            edges = new_graph_renderer.edge_renderer.data_source.data

            graph_renderer.node_renderer.data_source.data = nodes
            graph_renderer.edge_renderer.data_source.data = edges

            axis = new_network_builder.get_axis()

            network_builder.manual_set_lay_out(graph_renderer=graph_renderer, axis=axis)
