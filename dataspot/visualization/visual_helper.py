import os
import sys
from bokeh.themes import Theme
from jinja2 import Environment, FileSystemLoader


class VisualHelper:

    def __init__(self):
        pass

    @staticmethod
    def force_axis_usage(node, axis):
        all_values = list()
        lowest = int()
        highest = int()
        for value in axis.values():
            if value[1] < lowest:
                lowest = value[1]
            if value[1] > highest:
                highest = value[1]
            if value[1] not in all_values:
                all_values.append(value[1])
        distance = abs(lowest - highest)
        gap = distance / len(all_values)
        new_y = lowest - gap

        axis[node] = (0, new_y)

        return axis

    @staticmethod
    def list_network_nodes(callback_type,relationships, input_node):
        nodes = list()
        if callback_type == 'root':
            nodes = VisualHelper.list_network_nodes_root(relationships=relationships, input_node=input_node)
        elif callback_type == 'usage':
            nodes = VisualHelper.list_network_nodes_usage(relationships=relationships, input_node=input_node)
        else:
            pass
            # TODO: gebruik error

        return nodes

    @staticmethod
    def list_network_nodes_root(relationships, input_node):
        nodes = list()
        for node_key, node_source in relationships.items():
            if node_key == input_node:
                for node in node_source:
                    nodes.append(node)
                for root_node in nodes:
                    for root_node_key, root_node_source in relationships.items():
                        if root_node_key == root_node:
                            for node in root_node_source:
                                if node not in nodes:
                                    nodes.append(node)
        return nodes

    @staticmethod
    def list_network_nodes_usage(relationships, input_node):
        usage_nodes = list()
        for node_key, node_sources in relationships.items():
            if input_node in node_sources:
                usage_nodes.append(node_key)
                for node in usage_nodes:
                    for usage_node_key, usage_node_sources in relationships.items():
                        if node in usage_node_sources:
                            if usage_node_key not in usage_nodes:
                                usage_nodes.append(usage_node_key)

        return usage_nodes

    @staticmethod
    def list_nodes(network_builder, node_network_builder, callback_nodes, relationships):
        nodes = dict()
        print(11, 'hey')
        grouped_nodes = network_builder.get_grouped_nodes()
        grouped_colors = network_builder.get_grouped_colors()
        grouped_weights = network_builder.get_grouped_weights()
        grouped_legend = network_builder.get_grouped_legend()
        node_size_config = network_builder.get_node_size_config()
        levels = network_builder.get_levels()

        print(12, 'hey')

        node_network_builder.set_node_colors(nodes=callback_nodes, grouped_nodes=grouped_nodes,
                                             grouped_colors=grouped_colors)
        print(13, 'hey')

        node_network_builder.set_node_sizes(nodes=callback_nodes, relationships=relationships,
                                            node_size_config=node_size_config, grouped_weights=grouped_weights,
                                            levels=levels)
        print(14, 'hey')

        node_network_builder.set_node_scores(nodes=callback_nodes, relationships=node_network_builder.get_relationships(), levels=levels,
                                             grouped_weights=grouped_weights)
        print(15, 'hey')

        node_network_builder.set_node_labels(nodes=callback_nodes, grouped_nodes=grouped_nodes,
                                             grouped_legend=grouped_legend)

        print(16, 'hey')

        node_colors = node_network_builder.get_node_colors()

        print(17, 'hey')

        nodes['index'] = callback_nodes
        nodes['color'] = node_colors
        nodes['size'] = node_network_builder.get_node_sizes()
        nodes['root_score'] = node_network_builder.get_node_root_scores()
        nodes['usage_score'] = node_network_builder.get_node_usage_scores()
        nodes['label'] = node_network_builder.get_node_labels()

        return nodes

    @staticmethod
    def list_network_edges(callback_type, relationships, input_node, nodes, callback_nodes):
        edges = list()
        if callback_type == 'root':
            edges = VisualHelper.list_edges_root(relationships=relationships, input_node=input_node, root_nodes=nodes,
                                                 callback_nodes=callback_nodes)
        elif callback_type == 'usage':
            nodes.append(input_node)
            edges = VisualHelper.list_edges_usage(relationships=relationships, usage_nodes=nodes)
        else:
            pass
            # TODO: gebruik error

        return edges

    @staticmethod
    def list_edges_root(input_node, relationships, root_nodes, callback_nodes):
        edges = dict()
        edges_start = list()
        edges_end = list()
        for i in root_nodes:
            for node_key, node_source in relationships.items():
                if node_key == i:
                    if input_node in node_source:
                        for node in node_source:
                            if node == input_node:
                                edges_start.append(node)
                                edges_end.append(node_key)
                    else:
                        for node in node_source:
                            edges_start.append(node)
                            edges_end.append(node_key)
                            if node not in callback_nodes:
                                callback_nodes.append(node)

        edges["start"] = edges_start
        edges["end"] = edges_end

        return edges

    @staticmethod
    def list_edges_usage(usage_nodes, relationships):
        edges = dict()
        edges_start = list()
        edges_end = list()
        for usage_node in usage_nodes:
            for node_key, node_sources in relationships.items():
                if node_key == usage_node:
                    for node in node_sources:
                        if node in usage_nodes:
                            edges_start.append(node)
                            edges_end.append(node_key)

        edges["start"] = edges_start
        edges["end"] = edges_end

        return edges

    @staticmethod
    def setup_doc(doc):
        # 1: In order to retrieve the directory of the html file, the templates directory must first be loaded into the
        #    Environment.
        # 2: Load the dataspot HTML into template
        # 3: Attach the template to the working doc
        # 4: Load the styling file of the Bokeh visualization, also located in templates
        # 5: Attach the styling to the working doc
        env = Environment(loader=FileSystemLoader(os.path.join(sys.path[1], 'templates')))
        template = env.get_template('dataspot.html')
        doc.template = template
        doc.title = 'Dataspot'

        theme_template = Theme(os.path.join(sys.path[1], 'templates/theme.yml'))
        doc.theme = theme_template
        return doc
