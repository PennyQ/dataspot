import os
import json
import time


class TextFileWriter:

    def __init__(self):
        pass

    def write(self, scripts_path, data, title, timestamp, extension):
        if timestamp:
            timestr = time.strftime("%Y%m%d_%H%M%S")
            relationships_file = title + timestr + '.' + extension
        else:
            relationships_file = title + '.' + extension

        with open(os.path.join(scripts_path, relationships_file), 'w') as results:
            results.write(json.dumps(data))

        relationships_path = os.path.join(scripts_path, relationships_file)
        return relationships_path
