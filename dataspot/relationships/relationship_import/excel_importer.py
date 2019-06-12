from openpyxl import load_workbook


class ExcelImporter:

    def __init__(self):
        self.__relationships = dict()

    def set_relationships(self, ws):
        relationships = self.__relationships
        for row in ws.iter_rows(values_only=True):
            if row[0] in relationships:
                for ind, i in enumerate(row):
                    if ind > 0 and i is not None and i not in relationships[row[0]]:
                        relationships[row[0].lower()].append(i.lower())
            else:
                for ind, source in enumerate(row):
                    if ind > 0 and source is not None:
                        relationships[row[0].lower()] = list()
                        relationships[row[0].lower()].append(source.lower())

    def get_relationships(self):
        return self.__relationships

    def build(self, path):
        wb = load_workbook(path)
        for sheet in wb.sheetnames:
            ws = wb[sheet]
            self.set_relationships(ws=ws)
