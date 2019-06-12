import os
from bokeh.models import ColumnDataSource, CustomJS
from bokeh.models.widgets import Button, DataTable, TableColumn
from dataspot.network.nodes.nodes_statistics_networker import NodeStatisticsNetworker


class ReportHelper:

    def __init__(self):
        pass

    @staticmethod
    def get_report_source(network_builder):
        report_source = ColumnDataSource(data=dict())
        graph_renderer = network_builder.get_graph_render()

        report_source.data = {
            'Object Name': graph_renderer.node_renderer.data_source.data['index'],
            'Object Group': graph_renderer.node_renderer.data_source.data['label'],
            'Root Score': graph_renderer.node_renderer.data_source.data['root_score'],
            'Usage Score': graph_renderer.node_renderer.data_source.data['usage_score']
        }

        return report_source

    @staticmethod
    def get_statistics(config, report_source, network_builder):
        nodes = network_builder.get_nodes()
        for statistic in config['statistics']:
            node_statistics_networker = NodeStatisticsNetworker()
            node_statistics_networker.build(nodes=nodes, config=config, statistic=statistic)
            statistics = node_statistics_networker.get_node()
            report_source.data[statistic] = statistics

        return report_source

    @staticmethod
    def get_sources(report_source, network_builder):
        relationships = network_builder.get_relationships()
        nodes = network_builder.get_nodes()
        source_lists = list()
        for node in nodes:
            if node in relationships:
                if len(relationships[node]) != 0:
                    sources = relationships[node]
                    source_lists.append(sources)
                else:
                    source_lists.append(list())
            else:
                source_lists.append(list())

        max_length_sources = 0
        for i in source_lists:
            if len(i) > max_length_sources:
                max_length_sources = len(i)

        source_dict = dict()
        for i in range(1, max_length_sources):
            source_dict['Source ' + str(i)] = list()

        for i in range(1, max_length_sources):
            for source_list in source_lists:
                if len(source_list) == 0:
                    source_dict['Source ' + str(i)].append('')
                elif len(source_list) >= i:
                    source_dict['Source ' + str(i)].append(source_list[i - 1])
                else:
                    source_dict['Source ' + str(i)].append('')

        for key, value in source_dict.items():
            report_source.data[key] = value

        return report_source

    @staticmethod
    def set_button(source, path):
        button = Button(label="Download", button_type="success")
        button.callback = CustomJS(args=dict(source=source),
                                   code=open(os.path.join(os.path.abspath('../../'), path)).read())

        return button

    @staticmethod
    def set_table(source):
        columns = list()
        for key in source.data.keys():
            columns.append(TableColumn(field=key, title=key))

        table = DataTable(source=source, columns=columns, width=1200, scroll_to_selection= True, fit_columns=False)

        return table
