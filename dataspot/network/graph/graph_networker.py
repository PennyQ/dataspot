import networkx as nx
from bokeh.plotting import figure
from bokeh.palettes import Spectral4
from bokeh.models import Range1d
from bokeh.models.graphs import from_networkx, NodesAndLinkedEdges
from bokeh.models import MultiLine, Circle, Text, HoverTool, TapTool, StaticLayoutProvider
from dataspot.network.hierarchy.hierarchy_builder import HierarchyBuilder


class GraphNetworker:

    def __init__(self):
        pass

    @staticmethod
    def build_graph(relationships):
        graph = nx.DiGraph()

        graph.add_nodes_from(relationships.keys())

        for tables in relationships.values():
            for table in tables:
                if table not in graph:
                    graph.add_node(table)

        for table_key, table_value in relationships.items():
            for table in table_value:
                graph.add_edge(table, table_key)

        return graph

    @staticmethod
    def build_graph_renderer(graph, nodes, node_colors, node_sizes, node_scores, node_labels):
        graph_renderer = from_networkx(graph, nx.kamada_kawai_layout)

        graph_renderer.node_renderer.data_source.data['index'] = nodes
        graph_renderer.node_renderer.data_source.data['color'] = node_colors
        graph_renderer.node_renderer.data_source.data['size'] = node_sizes
        graph_renderer.node_renderer.data_source.data['root_score'] = node_scores[0]
        graph_renderer.node_renderer.data_source.data['usage_score'] = node_scores[1]
        graph_renderer.node_renderer.data_source.data['label'] = node_labels

        graph_renderer.node_renderer.glyph = Circle(size="size", fill_color="color")
        graph_renderer.node_renderer.selection_glyph = Circle(size="size", fill_color="color")
        graph_renderer.node_renderer.hover_glyph = Circle(size="size", fill_color="color")

        graph_renderer.edge_renderer.glyph = MultiLine(line_color="#CCCCCC", line_alpha=0.8, line_width=5)
        graph_renderer.edge_renderer.selection_glyph = MultiLine(line_color=Spectral4[2], line_width=5)
        graph_renderer.edge_renderer.hover_glyph = MultiLine(line_color=Spectral4[1], line_width=5)

        graph_renderer.selection_policy = NodesAndLinkedEdges()
        graph_renderer.inspection_policy = NodesAndLinkedEdges()

        return graph_renderer

    @staticmethod
    def list_y(node, nodes_list, keys_list, relationships):
        y_total = 3
        y_start = 1.5
        gap = y_total / (len(keys_list) + 1)

        if node in keys_list:
            for key in keys_list:
                if key == node:
                    count = 0
                    if key in nodes_list:
                        todo = list()
                        for node_key, node_sources in relationships.items():
                            if key in node_sources:
                                todo.append(node_key)
                        for node in todo:
                            count += 1
                            for node_key, node_sources in relationships.items():
                                if node in node_sources:
                                    todo.append(node_key)
                        y = (y_start - (count * gap))
                        return y
                    else:
                        y = y_start - (count * gap)
                        return y
        elif node in nodes_list:
            for node_key in nodes_list:
                if node_key == node:
                    if node_key in keys_list:
                        pass
                    else:
                        count = 0
                        todo = list()
                        for key, sources in relationships.items():
                            if node_key in sources:
                                todo.append(key)
                        for key in todo:
                            count += 1
                            for node_key, sources in relationships.items():
                                if key in sources:
                                    todo.append(node_key)
                        y = y_start - (count * gap)
                        return y

    @staticmethod
    def list_x(axis):
        conf = dict()
        for y in axis.values():
            conf[y[1]] = list()

        found_x = dict()
        for y in axis.values():
            found_x[y[1]] = list()

        for test in conf.keys():
            for x, y in axis.items():
                if test in y:
                    conf[test].append(x)

        for a, b in conf.items():
            for x, y in axis.items():
                if y[1] == a:
                    x_start = -1.5
                    x_total = 3
                    gap = x_total / (len(b) + 1)
                    test_x = x_start + gap
                    for c, d in found_x.items():
                        if c == a:
                            if test_x in d:
                                test_x = max(d) + gap
                                found_x[c].append(test_x)
                            else:
                                found_x[c].append(test_x)
                            axis[x][0] = test_x
        return axis

    @staticmethod
    def build_axis(x_range, y_range, relationships, nodes, force):
        nodes_list = list()
        keys_list = list()
        for key, tables in relationships.items():
            keys_list.append(key)
            for table in tables:
                nodes_list.append(table)

        hierarchy_builder = HierarchyBuilder()
        hierarchy_builder.build(x_range=x_range, y_range=y_range, relationships=relationships, force=force)
        coordinates = hierarchy_builder.get_coordinates()

        axis = dict()
        for node in nodes:
            if node in coordinates:
                axis[node] = tuple(coordinates[node])
        return axis

    @staticmethod
    def build_lay_out(graph_renderer, axis):
        graph_renderer.layout_provider = StaticLayoutProvider(graph_layout=axis)

        return graph_renderer

    @staticmethod
    def build_network(graph_renderer, plot_width, plot_height, x_range, y_range, grouped_colors, grouped_legend):
        network = figure(plot_width=plot_width, plot_height=plot_height, x_range=x_range, y_range=y_range)

        network.y_range = Range1d(-3, 3)
        network.x_range = Range1d(-3, 3)

        node_hover_tool = HoverTool(tooltips=[("Object:", "@index"), ("Object Group:", "@label"), ("Root Score:", "@root_score"), ("Usage Score:", "@usage_score")])
        network.add_tools(node_hover_tool, TapTool())

        network.renderers.append(graph_renderer)

        return network

    @staticmethod
    def build_legend(network, grouped_colors, grouped_legend):
        legend = dict()

        for group_color, color in grouped_colors.items():
            for group_label, label in grouped_legend.items():
                if group_color == group_label:
                    legend[label] = color

        x_pos_text = 0.6
        y_pos_text = 1.9

        x_pos_color = 0.5
        y_pos_color = 1.94

        for label, color in legend.items():
            network.add_glyph(Text(x=x_pos_text, y=y_pos_text, text=[label], text_font_size='10pt',
                                   text_color='#666666'))
            y_pos_text = y_pos_text - 0.1

            network.add_glyph(Circle(x=x_pos_color, y=y_pos_color, fill_color=[color][0], line_color=None,
                                     fill_alpha=0.8, size=10))
            y_pos_color = y_pos_color - 0.1

        return network
