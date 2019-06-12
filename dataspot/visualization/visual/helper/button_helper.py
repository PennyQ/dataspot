from dataspot.visualization.visual_helper import VisualHelper
from dataspot.relationships.relationships_helper import RelationshipHelper


class ButtonHelper:

    def __init__(self, relationships=None, network_builder=None, node_network_builder=None, callback_type=None, force=None):
        self.__relationships = relationships
        self.__network_builder = network_builder
        self.__node_network_builder = node_network_builder
        self.__callback_type = callback_type
        self.__graph_renderer = network_builder.get_graph_render()
        self.__force = force

    @staticmethod
    def get_callback_relationships(relationships, nodes, callback_type, input_node):
        if callback_type == 'root':
            nodes.append(input_node)

        callback_relationships = dict()
        for node in nodes:
            node_relationships = RelationshipHelper.get_relationships(node=node, relationships=relationships)

            callback_relationships = {**callback_relationships, **node_relationships}

        if callback_type == 'usage':
            nodes.append(input_node)

        return callback_relationships, nodes

    @staticmethod
    def get_callback_axis(network_builder, callback_relationships, nodes, callback_type, input_node, force):
        y_range = network_builder.get_y_range()
        x_range = network_builder.get_x_range()

        network_builder.set_axis(y_range=y_range, x_range=x_range, relationships=callback_relationships,
                                 nodes=nodes, force=force)
        axis = network_builder.get_axis()

        if callback_type == 'usage':
            axis = VisualHelper.force_axis_usage(node=input_node, axis=axis)

        return axis

    def callback(self, attr, old, new):
        if new:
            # strip blank spaces from input. Otherwise, the functions will not find the object.
            input_node = new.strip()

            axis_nodes = VisualHelper.list_network_nodes(callback_type=self.__callback_type, input_node=input_node,
                                                         relationships=self.__relationships)

            # For every node in the root nodes, find all the sources of that object. The end product is a subset of
            # the original relationships dictionary of the whole analysis set
            callback_relationships, axis_nodes = self.get_callback_relationships(relationships=self.__relationships,
                                                                                 nodes=axis_nodes,
                                                                                 callback_type=self.__callback_type,
                                                                                 input_node=input_node)

            # The edges for the network is calculated by means of the root nodes and the new subset of relationships
            edges = VisualHelper.list_network_edges(input_node=input_node,relationships=callback_relationships,
                                                    nodes=axis_nodes, callback_nodes=axis_nodes,
                                                    callback_type=self.__callback_type)

            # A new, correctly ordered list, based on the subset of relationships is formed. This to make sure the edges
            # and values correspond with the correct node
            nodes = VisualHelper.list_nodes(callback_nodes=axis_nodes, network_builder=self.__network_builder,
                                            node_network_builder=self.__node_network_builder,
                                            relationships=callback_relationships)

            # The new edges and nodes replace the original values of the graph_renderer
            self.__graph_renderer.node_renderer.data_source.data = nodes
            self.__graph_renderer.edge_renderer.data_source.data = edges

            # With the newly found data, a new axis is build
            axis = self.get_callback_axis(network_builder=self.__network_builder,
                                          callback_relationships=callback_relationships, nodes=axis_nodes,
                                          force=self.__force,
                                          callback_type=self.__callback_type,
                                          input_node=input_node)

            # renew the network in the current layout
            self.__network_builder.set_lay_out(graph_renderer=self.__graph_renderer, axis=axis)

        else:
            pass
