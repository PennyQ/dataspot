from bokeh.layouts import row
from dataspot.visualization.visualizer import Visualizer
from dataspot.visualization.visual.report_builder import ReportBuilder
from dataspot.visualization.visual.helper.report_helper import ReportHelper


class ReportVisualizer(Visualizer):

    def __init__(self, network_builder):
        self.__network_builder = network_builder
        self.__layout = None
        self.__report_source = None

    def set_source(self):
        report_builder = ReportBuilder(network_builder=self.__network_builder)
        report_builder.build()
        report_source = report_builder.get_report_source()
        self.__report_source = report_source

    def get_source(self):
        return self.__report_source

    def set_layout(self):
        button_js_path = "templates/download.js"
        button = ReportHelper.set_button(source=self.__report_source, path=button_js_path)

        table = ReportHelper.set_table(source=self.__report_source)

        layout = row(table, button)
        self.__layout = layout

    def get_layout(self):
        return self.__layout

    def build(self):
        self.set_source()
        self.set_layout()
