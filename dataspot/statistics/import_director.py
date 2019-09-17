import os
from dataspot.statistics.excel_importer import ExcelImporter
from dataspot.relationships.writer.text_file_writer import TextFileWriter


class ImportDirector:

    def __init__(self):
        pass

    @staticmethod
    def build(path):
        relationships = dict()
        for file in os.listdir(path=path):
            file_path = os.path.join(path, file)
            importer = ExcelImporter()
            importer.build(path=file_path)
            imported_relationships = importer.get_relationships()
            relationships = {**relationships, **imported_relationships}

        TextFileWriter().write(scripts_path='/Users/patrickdehoon/PycharmProjects/Dataspot/examples',
                               data=relationships, timestamp=True, extension='json', title='clan_statistics_')


path = '/Users/patrickdehoon/PycharmProjects/Dataspot/examples/clan/statistics/'

ImportDirector.build(path=path)