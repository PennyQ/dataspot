

class LegendHelper:

    @staticmethod
    def get_list(grouped_item):

        result = list()
        for key, value in grouped_item.items():
            result.append(value)

        return result

    @staticmethod
    def get_legend(colors, legend_names):
        legend = """<ul>"""

        for color, legend_name in zip(colors, legend_names):
            item = """<li style="color:{};"><span style="color:black">{}</span></li>""".format(color, legend_name)
            legend += item

        legend += """</ul>"""

        return legend
