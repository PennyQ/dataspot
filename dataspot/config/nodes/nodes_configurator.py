from dataspot.config.configurator import Configurator


class NodesConfigurator(Configurator):
    """

    """

    def __init__(self, config, relationships, available_nodes):
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
        self.__available_nodes = available_nodes
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

    def get_available_nodes(self):
        return self.__available_nodes

    def set_grouped_nodes_config(self, config, relationships, available_nodes):
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
                    to_exclude.append(found_node)

        ungrouped_nodes = list(set(available_nodes) - set(to_exclude))

        grouped_nodes['unknown'] = list()
        for node in ungrouped_nodes:
            grouped_nodes['unknown'].append(node)

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
        available_nodes = self.get_available_nodes()
        self.set_grouped_nodes_config(config=config, relationships=relationships, available_nodes=available_nodes)

