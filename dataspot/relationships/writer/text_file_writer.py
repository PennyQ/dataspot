import os
import json
import time


class TextFileWriter:
    """

    """

    @staticmethod
    def write(scripts_path, data, title, timestamp, extension):
        """

        :param scripts_path:
        :type scripts_path:
        :param data:
        :type data:
        :param title:
        :type title:
        :param timestamp:
        :type timestamp:
        :param extension:
        :type extension:
        :return:
        :rtype:
        """
        if timestamp:
            timestr = time.strftime("%Y%m%d_%H%M%S")
            relationships_file = title + timestr + '.' + extension
        else:
            relationships_file = title + '.' + extension

        with open(os.path.join(scripts_path, relationships_file), 'w') as results:
            results.write(json.dumps(data))

        relationships_path = os.path.join(scripts_path, relationships_file)
        return relationships_path
