

class RelationshipHelper:

    @staticmethod
    def build_relationships(callback_nodes, relationships):
        new_relationships = dict()

        for callback_node in callback_nodes:
            if callback_node in relationships:
                new_relationships[callback_node] = list()
                for node in relationships[callback_node]:
                    if node in callback_nodes:
                        new_relationships[callback_node].append(node)

        return new_relationships
