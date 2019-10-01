from dataspot.network.hierarchy.hierarchy_helper import HierarchyHelper


class HierarchyBuilder:

    def __init__(self):
        self.__root_list = None
        self.__y_levels = None
        self.__x_levels = None
        self.__levels = None
        self.__coordinates = None

    def set_y_levels(self, levels):
        self.__y_levels = HierarchyHelper.list_y_levels(levels=levels)

    def get_y_levels(self):
        return self.__y_levels

    def set_levels(self, levels):
        self.__levels = HierarchyHelper.list_levels(levels_dict=levels)

    def get_levels(self):
        return self.__levels

    def set_x_levels(self):
        self.__x_levels = HierarchyHelper.list_x_levels(y_levels=self.__y_levels, levels=self.__levels)

    def get_x_levels(self):
        return self.__x_levels

    def set_coordinates(self, x_range, y_range):
        levels = self.get_levels()
        y_levels = self.get_y_levels()
        x_levels = self.get_x_levels()
        coordinates = HierarchyHelper.calc_y_coordinates(y_range=y_range, levels=levels, y_levels=y_levels)
        coordinates = HierarchyHelper.calc_x_coordinates(x_range=x_range, levels=levels, x_levels=x_levels,
                                                         coordinates=coordinates)
        self.__coordinates = coordinates

    def get_coordinates(self):
        return self.__coordinates

    def build(self, x_range, y_range, levels):
        self.set_y_levels(levels=levels)
        self.set_levels(levels=levels)
        self.set_x_levels()
        self.set_coordinates(x_range=x_range, y_range=y_range)
