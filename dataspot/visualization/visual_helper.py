import os
import sys
from bokeh.themes import Theme
from jinja2 import Environment, FileSystemLoader


class VisualHelper:

    @staticmethod
    def list_network_nodes(callback_type,relationships, input_node):
        nodes = list()
        if callback_type == 'root':
            nodes = VisualHelper.list_network_nodes_root(relationships=relationships, input_node=input_node)
        elif callback_type == 'usage':
            nodes = VisualHelper.list_network_nodes_usage(relationships=relationships, input_node=input_node)

        return nodes

    @staticmethod
    def list_network_nodes_root(relationships, input_node):
        root_nodes = list()

        if input_node in relationships:
            for node in relationships[input_node]:
                root_nodes.append(node)
            for root_node in root_nodes:
                if root_node in relationships:
                    for node in relationships[root_node]:
                        if node not in root_nodes:
                            root_nodes.append(node)

        if input_node not in root_nodes:
            root_nodes.append(input_node)

        root_nodes = list(set(root_nodes))
        return root_nodes

    @staticmethod
    def list_network_nodes_usage(relationships, input_node):
        usage_nodes = list()
        for node_key, node_sources in relationships.items():
            if input_node in node_sources:
                usage_nodes.append(node_key)
                for node in usage_nodes:
                    for usage_node_key, usage_node_sources in relationships.items():
                        if node in usage_node_sources and usage_node_key not in usage_nodes:
                            usage_nodes.append(usage_node_key)

        if input_node not in usage_nodes:
            usage_nodes.append(input_node)

        usage_nodes = list(set(usage_nodes))
        return usage_nodes

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
