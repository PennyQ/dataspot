from dataspot.config.configurator import Configurator


class WeightsConfigurator(Configurator):
    """

    """
    def __init__(self, config, grouped_nodes):
        """
        :param config: The config parameter is a dictionary containing all of the Dataspot basic configurations. An
                       example of the basic structure can be found in examples/dataspot_config_example.json
        :type config: dict
        :param grouped_nodes:
        :type grouped_nodes:
        """
        self.__config = config
        self.__grouped_nodes = grouped_nodes
        self.__grouped_weights = None

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

    def set_grouped_nodes(self, grouped_nodes):
        """
        :param grouped_nodes:
        :type grouped_nodes:
        """
        self.__grouped_nodes = grouped_nodes

    def get_grouped_nodes(self):
        """
        :return:
        :rtype:
        """
        return self.__grouped_nodes

    def set_grouped_weights_config(self, config, grouped_nodes):
        """
        :param config: The config parameter is a dictionary containing all of the Dataspot basic configurations. An
                       example of the basic structure can be found in examples/dataspot_config_example.json
        :type config: dict
        :param grouped_nodes:
        :type grouped_nodes:
        """
        grouped_weights = dict()
        weights = list()

        if not isinstance(config, dict):
            raise TypeError("The configuration that has been provided is not of a dictionary type")

        if not isinstance(config['relationships_config']['groups'], dict):
            raise TypeError("The groups configuration should be provided in a dictionary")

        if not isinstance(grouped_nodes, dict):
            raise TypeError("The configuration that has been provided is not of a dictionary type")

        for group, config_key in config['relationships_config']['groups'].items():
            if 'weights' in config_key.keys():
                for i in config['weights'].keys():
                    weights.append(int(i))
            elif 'weights_all' in config_key.keys():
                weight = config_key['weights_all']
                weights.append(weight)

        for weight in set(weights):
            grouped_weights[weight] = list()

        for group, config_key in config['relationships_config']['groups'].items():
            if 'weights' in config_key.keys():
                for weight_key, nodes in config_key['weights'].items():
                    for node in nodes:
                        grouped_weights[weight_key].append(node)
            elif 'weights_all' in config_key.keys():
                for groups, nodes in grouped_nodes.items():
                    if groups == group:
                        weight = config_key['weights_all']
                        for node in nodes:
                            grouped_weights[weight].append(node)

        for node in grouped_nodes['unknown']:
            grouped_weights[1].append(node)

        self.__grouped_weights = grouped_weights

    def get_grouped_weights_config(self):
        """
        :return:
        :rtype:
        """
        return self.__grouped_weights

    def build(self):
        """
        """
        config = self.get_config()
        grouped_nodes = self.get_grouped_nodes()
        self.set_grouped_weights_config(config=config, grouped_nodes=grouped_nodes)
