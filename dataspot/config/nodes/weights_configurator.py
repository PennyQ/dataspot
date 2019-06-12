from dataspot.config.configurator import Configurator


class WeightsConfigurator(Configurator):

    def __init__(self):
        self.__grouped_weights = None

    def set_config(self, config, grouped_nodes):
        grouped_weights = dict()
        weights = list()

        # 1: Iterate over each group key
        # 2: Per group key, iterate over the config_old keys
        # 3: First, all the different weights are found and put in a list
        # 4: When the key 'weights' is found, iterate over the values in the list and append to the weights list
        # 5: When the key 'weights_all' is found it is appended to the weights list
        # 6: Duplicates are removed from the weights list via the set command
        # 7: Iterate over the weights list and put it as a key in the grouped_weights dict
        for group in config['relationships_config']['groups'].keys():
            for configs in config['relationships_config']['groups'][group]:
                for config_type, config_value in configs.items():
                    if config_type == 'weights':
                        for i in config_value.keys():
                            weights.append(int(i))
                    elif config_type == 'weights_all':
                        weights.append(config_value)

        for weight in set(weights):
            grouped_weights[weight] = list()

        # 1: Iterate over each group key
        # 2: Per group key, iterate over the config_old keys
        # 3: If the config_old key 'weights' is found, iterate over the weight_keys and the respective list of nodes
        # 4: At the same time, iterate over weight_keys in the grouped_weights dict
        # 5: When the weights match, the respective nodes in the list will be added to the weight in the
        #    grouped_weights dict.
        # 6: If the config_old key 'weights_all' is found, iterate over the grouped_nodes items
        # 7: If the group in 'grouped_names' match the group config_old key, iterate over the nodes in the
        #    grouped_nodes
        # 8: The nodes is appended to the respective weight in the grouped_weights dict
        for group in config['relationships_config']['groups'].keys():
            for configs in config['relationships_config']['groups'][group]:
                for config_key, config_value in configs.items():
                    if config_key == 'weights':
                        for weight_key, nodes in config_value.items():
                            for weight in grouped_weights.keys():
                                if weight_key == str(weight):
                                    for node in nodes:
                                        grouped_weights[weight].append(node)
                    elif config_key == 'weights_all':
                        for groups, nodes in grouped_nodes.items():
                            if groups == group:
                                for node in nodes:
                                    grouped_weights[config_value].append(node)

        self.__grouped_weights = grouped_weights

    def get_config(self):
        return self.__grouped_weights

    def build(self, config, grouped_nodes):
        self.set_config(config=config, grouped_nodes=grouped_nodes)