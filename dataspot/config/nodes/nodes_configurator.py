from dataspot.config.configurator import Configurator


class NodesConfigurator(Configurator):
    """

    """

    def __init__(self, config, relationships):
        """
        :param config: The config parameter is a dictionary containing all of the Dataspot basic configurations. An
                       example of the basic structure can be found in examples/dataspot_config_example.json
        :type config: dict
        :param relationships: A relationships dictionary, which has one object (aka node) as its keys, with each key
                             having a list of source objects (aka nodes) put together in a list object as its values.
        :type relationships: dict
        """
        self.__config = config
        self.__relationships = relationships
        self.__grouped_nodes = None

    def set_config(self, config):
        """
        :param config: The config parameter is a dictionary containing all of the Dataspot basic configurations. An
                       example of the basic structure can be found in examples/dataspot_config_example.json
        :type config: dict
        """
        self.__config = config

    def get_config(self):
        """
        :return: The config parameter is a dictionary containing all of the Dataspot basic configurations. An
                 example of the basic structure can be found in examples/dataspot_config_example.json
        :rtype: dict
        """
        return self.__config

    def set_relationships(self, relationships):
        """
        :param relationships: A relationships dictionary, which has one object (aka node) as its keys, with each key
                             having a list of source objects (aka nodes) put together in a list object as its values.
        :type relationships: dict
        """
        if not isinstance(relationships, dict):
            raise TypeError("The relationships that have been provided are not of a dictionary type")

        self.__relationships = relationships

    def get_relationships(self):
        """
        :return: A relationships dictionary, which has one object (aka node) as its keys, with
                 each key having a list of source objects (aka nodes) put together in a list object as its
                 values.
        :rtype: dict
        """
        return self.__relationships

    def set_grouped_nodes_config(self, config, relationships):
        """
        :param config: The config parameter is a dictionary containing all of the Dataspot basic configurations. An
                       example of the basic structure can be found in examples/dataspot_config_example.json
        :type config: dict
        :param relationships:
        :type relationships:
        """
        grouped_nodes = dict()
        to_exclude = list()

        if not isinstance(config, dict):
            raise TypeError("The configuration that has been provided is not of a dictionary type")

        if not isinstance(config['relationships_config']['groups'], dict):
            raise TypeError("The groups configuration should be provided in a dictionary")

        if not isinstance(relationships, dict):
            raise TypeError("The configuration that has been provided is not of a dictionary type")

        for group, config in config['relationships_config']['groups'].items():
            grouped_nodes[group] = list()
            if 'nodes' in config.keys():
                for node in config['nodes']:
                    grouped_nodes[group].append(node)
                    to_exclude.append(node)
            elif 'args' in config.keys():
                found_nodes = list()
                for arg in config['args']:
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
                    grouped_nodes[group].append(found_node)

        # TODO: When neither 'nodes' nor 'args' are specified, nodes should be put in a group called 'ungrouped'.

        self.__grouped_nodes = grouped_nodes

    def get_grouped_nodes_config(self):
        """
        :return:
        :rtype:
        """
        return self.__grouped_nodes

    def build(self):
        """
        """
        config = self.get_config()
        relationships = self.get_relationships()
        self.set_grouped_nodes_config(config=config, relationships=relationships)

# # 1: Iterate over each group key
# # 2: Per group key, iterate over the config_old keys
# # 3: When the key 'nodes' is found, iterate over the values in the list
# # 4: Every nodes is added to the group dictionary, to the respective group it belongs to
# # 5: Every nodes is added to the 'to_exclude' list. This is to prevent the nodes to be added twice to the
# #    group dictionary. This could theoretically happen with the args key.
# # 6: When the args key is found, iterate over the values in the list
# # 7: First, iterate over the relationships keys. Every key is a nodes. When a nodes is matched with the arg,
# #    and it is not found in the 'to_exclude' list, it will be appended to the found_nodes list.
# # 8: Second, do the same thing for the nodes in the values list, as was done in step 7.
# # 9: Filter out duplicate nodes via running the set command on the found_nodes list.
# # 10: Add the table to the grouped_nodes dict for the respective key
# for group_key, group_value in config['relationships_config']['groups'].items():
#     grouped_nodes[group_key] = list()
#     for config in group_value:
#         for config_key, config_value in config.items():
#             if config_key == 'nodes':
#                 for node in config_value:
#                     grouped_nodes[group_key].append(node)
#                     to_exclude.append(node)
#             elif config_key == 'args':
#                 found_nodes = list()
#                 for arg in config_value:
#                     for node in relationships.keys():
#                         if node.find(arg) != -1:
#                             if to_exclude.count(node) == 0:
#                                 found_nodes.append(node)
#                                 to_exclude.append(node)
#                     for nodes in relationships.values():
#                         for node in nodes:
#                             if node.find(arg) != -1:
#                                 if to_exclude.count(node) == 0:
#                                     found_nodes.append(node)
#                                     to_exclude.append(node)
#                 for found_node in set(found_nodes):
#                     grouped_nodes[group_key].append(found_node)
