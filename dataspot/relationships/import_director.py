import os
from dataspot.relationships.relationship_import.excel_importer import ExcelImporter
from dataspot.relationships.writer.text_file_writer import TextFileWriter


class ImportDirector:

    def __init__(self, relationships):
        self.__relationships = relationships

    def get_relationships(self):
        return self.__relationships

    def build(self, path):
        relationships = self.get_relationships()
        for file in os.listdir(path=path):
            if file[file.find('.'): len(file)] in ['.xlsx', '.xlsm', '.xltx', '.xltm']:
                file_path = os.path.join(path, file)
                importer = ExcelImporter()
                importer.build(path=file_path)
                imported_relationships = importer.get_relationships()
                relationships = {**relationships, **imported_relationships}

        TextFileWriter().write(scripts_path=os.path.join(os.path.abspath('../../'), 'examples/manual_relationships'),
                               data=relationships, timestamp=True, extension='json',
                               title='manual_relationships_example_')
