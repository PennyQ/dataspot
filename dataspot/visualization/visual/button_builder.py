from bokeh.models.widgets import Select, TextInput
from dataspot.visualization.visual.helper.button_callback import ButtonCallback


class ButtonBuilder:

    def __init__(self, network_builder):
        self.__config = None
        self.__button_config = None
        self.__network_builder = network_builder
        self.__button_title = None
        self.__button_type = None
        self.__force = None
        self.__buttons = None

    def get_network_builder(self):
        return self.__network_builder

    def set_config(self):
        network_builder = self.get_network_builder()
        config = network_builder.get_config()
        self.__config = config["button_config"]["buttons"]

    def get_config(self):
        return self.__config

    def set_button_config(self, config):
        self.__button_config = config

    def get_button_config(self):
        return self.__button_config

    def set_button_title(self):
        button_config = self.get_button_config()
        button_title = button_config["title"]
        self.__button_title = button_title

    def get_button_title(self):
        return self.__button_title

    def set_type(self):
        button_config = self.get_button_config()
        button_type = button_config["type"]
        self.__button_type = button_type

    def get_button_type(self):
        return self.__button_type

    def get_text_button(self):
        button_title = self.get_button_title()
        network_builder = self.get_network_builder()
        button_type = self.get_button_type()
        button = TextInput(title=button_title)
        button.on_change('value', ButtonCallback(network_builder=network_builder, callback_type=button_type).callback)
        return button

    def get_dropdown_button(self):
        button_title = self.get_button_title()
        network_builder = self.get_network_builder()
        button_type = self.get_button_type()
        golden_sources = network_builder.get_golden_sources()
        button = Select(title=button_title, options=golden_sources, value=golden_sources[0])
        button.on_change('value', ButtonCallback(network_builder=network_builder, callback_type=button_type).callback)

        return button

    def set_buttons(self):
        buttons = list()
        config = self.get_config()

        for button in config.keys():
            self.set_button_config(config=config[button])
            self.set_button_title()
            self.set_type()

            if config[button]["button_type"] == 'text':
                button = self.get_text_button()
                buttons.append(button)

            elif config[button]["button_type"] == 'dropdown':
                button = self.get_dropdown_button()
                buttons.append(button)

        self.__buttons = buttons

    def get_buttons(self):
        return self.__buttons

    def build(self):
        self.set_config()
        self.set_buttons()
