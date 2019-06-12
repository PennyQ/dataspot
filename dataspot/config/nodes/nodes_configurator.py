from dataspot.config.configurator import Configurator


class NodesConfigurator(Configurator):

    def __init__(self):
        self.__grouped_nodes = None

    def set_config(self, config, relationships):
        grouped_nodes = dict()
        to_exclude = list()

        # 1: Iterate over each group key
        # 2: Per group key, iterate over the config_old keys
        # 3: When the key 'nodes' is found, iterate over the values in the list
        # 4: Every nodes is added to the group dictionary, to the respective group it belongs to
        # 5: Every nodes is added to the 'to_exclude' list. This is to prevent the nodes to be added twice to the
        #    group dictionary. This could theoretically happen with the args key.
        # 6: When the args key is found, iterate over the values in the list
        # 7: First, iterate over the relationships keys. Every key is a nodes. When a nodes is matched with the arg, and
        #    it is not found in the 'to_exclude' list, it will be appended to the found_nodes list.
        # 8: Second, do the same thing for the nodes in the values list, as was done in step 7.
        # 9: Filter out duplicate nodes via running the set command on the found_nodes list.
        # 10: Add the table to the grouped_nodes dict for the respective key
        for group_key, group_value in config['relationships_config']['groups'].items():
            grouped_nodes[group_key] = list()
            for config in group_value:
                for config_key, config_value in config.items():
                    if config_key == 'nodes':
                        for node in config_value:
                            grouped_nodes[group_key].append(node)
                            to_exclude.append(node)
                    elif config_key == 'args':
                        found_nodes = list()
                        for arg in config_value:
                            for node in relationships.keys():
                                if node.find(arg) != -1:
                                    if to_exclude.count(node) == 0:
                                        found_nodes.append(node)
                                        to_exclude.append(node)
                            for nodes in relationships.values():
                                for node in nodes:
                                    if node.find(arg) != -1:
                                        if to_exclude.count(node) == 0:
                                            found_nodes.append(node)
                                            to_exclude.append(node)
                        for found_node in set(found_nodes):
                            grouped_nodes[group_key].append(found_node)

        self.__grouped_nodes = grouped_nodes

    def get_config(self):
        return self.__grouped_nodes

    def build(self, config, relationships):
        self.set_config(config=config, relationships=relationships)
