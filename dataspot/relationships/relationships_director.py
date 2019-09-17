from dataspot.parsers.sql.teradata.teradata_parser import TeradataParser
import json


class RelationshipsDirector:

    @staticmethod
    def build(scripts, parser_config_path):

        relationships = dict()
        for script_type, script_path in scripts.items():
            if script_type == 'TERADATA':
                parser_config_path = open(parser_config_path)
                parser_config = json.load(parser_config_path)
                parser_config_path.close()
                teradata_parser = TeradataParser(parser_config=parser_config['teradata'], scripts=script_path)
                teradata_parser.parse()
                found_relationships = teradata_parser.get_relationships()
                relationships = {**relationships, **found_relationships}

            else:
                raise TypeError("The specified syntax is not supported in this version of Dataspot")

        return relationships

