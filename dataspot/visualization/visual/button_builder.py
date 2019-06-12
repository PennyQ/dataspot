from bokeh.models.widgets import Select, TextInput
from dataspot.visualization.visual.helper.button_helper import ButtonHelper


class ButtonBuilder:

    def __init__(self, button_config, relationships, network_builder, node_network_builder):
        self.__button_config = button_config
        self.__relationships = relationships
        self.__network_builder = network_builder
        self.__node_network_builder = node_network_builder
        self.__button_title = None
        self.__type = None
        self.__force = None
        self.__buttons = None

    def set_button_title(self, button_config):
        button_title = button_config["title"]
        self.__button_title = button_title

    def set_type(self, button_config):
        type = button_config["type"]
        self.__type = type

    def set_force(self, button_config):
        force = button_config["force"]
        self.__force = force

    def get_text_button(self):
        button = TextInput(title=self.__button_title)
        button.on_change('value', ButtonHelper(relationships=self.__relationships,
                                               network_builder=self.__network_builder,
                                               node_network_builder=self.__node_network_builder,
                                               callback_type=self.__type, force=self.__force).callback)
        return button

    def get_dropdown_button(self):
        network_builder = self.__network_builder
        golden_sources = network_builder.get_golden_sources()
        button = Select(title=self.__button_title, options=golden_sources, value=golden_sources[0])
        button.on_change('value', ButtonHelper(relationships=self.__relationships,
                                               network_builder=self.__network_builder,
                                               node_network_builder=self.__node_network_builder,
                                               callback_type=self.__type, force=self.__force).callback)

        return button

    def get_buttons(self):
        return self.__buttons

    def build(self):
        buttons = list()
        button_config = self.__button_config["buttons"]

        for button in button_config.keys():
            self.set_button_title(button_config=button_config[button])
            self.set_type(button_config=button_config[button])
            self.set_force(button_config=button_config[button])

            if button_config[button]["button_type"] == 'text':
                button = self.get_text_button()
                buttons.append(button)

            elif button_config[button]["button_type"] == 'dropdown':
                button = self.get_dropdown_button()
                buttons.append(button)

        self.__buttons = buttons
