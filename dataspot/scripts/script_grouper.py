import os


class ScriptGrouper:

    def __init__(self):
        pass

    @staticmethod
    def validate(script):
        SUPPORTED_TYPES = ["TERADATA"]

        f = open(script)
        line = f.readline()
        f.close()
        if line.find('#DATASPOT') != -1:
            script_type = line[line.find('-')+1:]

            if script_type.strip() in SUPPORTED_TYPES:
                return script_type.strip()
            else:
                raise TypeError("The specified syntax is not supported in this version of Dataspot")
        else:
            raise TypeError("Dataspot could not find the type of syntax for this script")

    @staticmethod
    def group(scripts_path):
        scripts = list()
        grouped_scripts = dict()

        for script in os.listdir(scripts_path):
            if script.find('dataspot') != -1:
                os.remove(os.path.join(scripts_path, script))

        for script in os.listdir(scripts_path):
            if script.find('dataspot') == -1 and script.find('.sql') != -1:
                scripts.append(os.path.join(scripts_path, script))

        for script in scripts:
            script_type = ScriptGrouper.validate(script=script)
            if script_type not in grouped_scripts.keys():
                grouped_scripts[script_type] = list()
                grouped_scripts[script_type].append(script)
            else:
                grouped_scripts[script_type].append(script)

        return grouped_scripts
