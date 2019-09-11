import os
from dataspot.relationships.relationship_import.excel_importer import ExcelImporter
from dataspot.relationships.writer.text_file_writer import TextFileWriter


class ImportDirector:

    def __init__(self):
        pass

    @staticmethod
    def build(path):
        relationships = dict()
        for file in os.listdir(path=path):
            if file[file.find('.'): len(file)] in ['.xlsx', '.xlsm', '.xltx', '.xltm']:
                file_path = os.path.join(path, file)
                importer = ExcelImporter()
                importer.build(path=file_path)
                imported_relationships = importer.get_relationships()
                relationships = {**relationships, **imported_relationships}

        TextFileWriter().write(scripts_path='/Users/patrickdehoon/Projecten/prive/dataspot/examples',
                               data=relationships, timestamp=True, extension='json', title='clan_relationships_')




path = '/Users/patrickdehoon/Projecten/prive/dataspot/examples/clan/relationships'
ImportDirector.build(path=path)