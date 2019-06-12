from dataspot.network.hierarchy.hierarchy_helper import HierarchyHelper


class HierarchyBuilder:

    def __init__(self):
        self.__root_list = None
        self.__y_levels = None
        self.__x_levels = None
        self.__levels = None
        self.__coordinates = None

    def set_root_list(self, relationships):
        self.__root_list = HierarchyHelper.list_roots(relationships=relationships)

    def set_y_levels(self, relationships, force):
        self.__y_levels = HierarchyHelper.get_y_levels(root_list=self.__root_list, relationships=relationships, force=force)

    def set_levels(self):
        self.__levels = HierarchyHelper.list_levels(levels_dict=self.__y_levels)

    def set_x_levels(self):
        self.__x_levels = HierarchyHelper.list_x_levels(y_levels=self.__y_levels, levels=self.__levels)

    def set_coordinates(self, x_range, y_range, force):
        coordinates = HierarchyHelper.calc_y_coordinates(y_range=y_range, levels=self.__levels, y_levels=self.__y_levels, force=force)
        coordinates = HierarchyHelper.calc_x_coordinates(x_range=x_range, levels=self.__levels, x_levels=self.__x_levels,
                                                         coordinates=coordinates)
        self.__coordinates = coordinates

    def get_coordinates(self):
        return self.__coordinates

    def build(self, x_range, y_range, relationships, force):
        self.set_root_list(relationships=relationships)
        self.set_y_levels(relationships=relationships, force=force)
        self.set_levels()
        self.set_x_levels()
        self.set_coordinates(x_range=x_range, y_range=y_range, force=force)
