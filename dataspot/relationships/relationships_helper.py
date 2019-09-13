

class RelationshipHelper:

    @staticmethod
    def get_relationships(node, relationships):
        new_relationships = dict()
        cur_key = list()
        done = list()

        if node in relationships:
            new_relationships[node] = relationships[node]
            cur_key.append(node)
            new_relationships = RelationshipHelper.build_relationships(cur_key=cur_key, done=done,
                                                                       new_relationships=new_relationships,
                                                                       relationships=relationships)

        return new_relationships

    @staticmethod
    def build_relationships(cur_key, done, new_relationships, relationships):

        if len(relationships[cur_key[0]]) > 0:
            for child_node in relationships[cur_key[0]]:
                if child_node not in done:

                    if child_node in relationships:
                        done.append(child_node)
                        new_relationships[child_node] = relationships[child_node]
                        cur_key.insert(0, child_node)
                        RelationshipHelper.build_relationships(cur_key=cur_key, done=done,
                                                               new_relationships=new_relationships,
                                                               relationships=relationships)
                    else:
                        done.append(child_node)
                        RelationshipHelper.build_relationships(cur_key=cur_key, done=done,
                                                               new_relationships=new_relationships,
                                                               relationships=relationships)
        else:
            cur_key.pop(0)
            if len(cur_key) == 0:
                return new_relationships
            else:
                RelationshipHelper.build_relationships(cur_key=cur_key, done=done, new_relationships=new_relationships,
                                                       relationships=relationships)

        return new_relationships
