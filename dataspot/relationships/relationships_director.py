from dataspot.relationships.teradata_dissector import TeradataDissector


class RelationshipsDirector:

    def __init__(self):
        pass

    @staticmethod
    def build(scripts):
        relationships = dict()
        for script_type, script_path in scripts.items():
            if script_type == 'TERADATA':
               for script in script_path:
                    teradata_dissector = TeradataDissector()
                    result = teradata_dissector.create_relationships(script=script)
                    relationships = {**relationships, **result}
            else:
                raise TypeError("The specified syntax is not supported in this version of Dataspot")

        return relationships

