from dataspot.visualization.visual.helper.report_helper import ReportHelper


class ReportBuilder:

    def __init__(self, network_builder):
        self.__config = network_builder.get_config()
        self.__network_builder = network_builder
        self.__report_source = None

    def set_sources(self):
        report_source = ReportHelper.get_sources(report_source=self.__report_source,
                                                 network_builder=self.__network_builder)
        self.__report_source = report_source

    def set_statistics(self):
        report_source = ReportHelper.get_statistics(config=self.__config, network_builder=self.__network_builder,
                                                    report_source=self.__report_source)

        self.__report_source = report_source

    def set_report_source(self):
        report_source = ReportHelper.get_report_source(network_builder=self.__network_builder)
        self.__report_source = report_source

    def get_report_source(self):
        return self.__report_source

    def build(self):
        self.set_report_source()
        if 'statistics' in self.__config:
            self.set_statistics()
        self.set_sources()
