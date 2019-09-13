#!/usr/bin/python
import os
import click
import json
import six
from pyfiglet import figlet_format
from termcolor import colored
from dataspot.scripts.script_grouper import ScriptGrouper
from dataspot.relationships.relationships_director import RelationshipsDirector
from dataspot.relationships.writer.text_file_writer import TextFileWriter


@click.command()
@click.option('--scripts_path', default=os.path.join(os.path.abspath('../../'), 'examples/clan/scripts'),
              prompt='Please enter the location of the directory that contains the scripts',
              type=click.Path(exists=True), help='Enter the full path of the directory where the scripts are stored')
@click.option('--config_path', default=os.path.join(os.path.abspath('../'),'dataspot_clan_config.json'),
              prompt='Please enter the path to the configuration file (JSON)', type=click.Path(exists=True),
              help='Enter the full path of the configuration file, which is in a JSON format.')
@click.option('--manual/--no_manual', default=True, prompt='Do you want to add a prepared dictionary?',
              help='Dataspot offers the possibility to include manually prepared relations. '
                   'This file needs to follow the JSON convention.')
@click.option('--statistics/--no_statistics', default=False, prompt='Do you want to add user statistics?',
              help='Dataspot offers the possibility to include user statistics. '
                   'This file needs to follow the JSON convention.')
def cli(config_path, scripts_path,  manual, statistics):
    """
    The command line interface guides the user through the set-up of their script analysis.

    :param config_path: The path/filename of the JSON formatted config_old file
    :type config_path: str
    :param scripts_path: The path where the scripts are located
    :type scripts_path: str
    :param manual: A boolean operator indicating if the user wants to add relationships which were defined manually.
                   Manually added relationships should be put in a .txt file, following a dictionary format
    :type manual: bool
    :param statistics: A boolean operator indicating if the user wants to add object statistics from a JSON file.
    :type statistics: bool

    If statistics are chosen to be included, the following parameter needs to be filled in:
        :param object_statistics_path: The path where the statistics are located
        :type object_statistics_path: str

    """

    # The parser configuration must exist in the main folder of Dataspot
    parser_config_path = os.path.abspath('parser_config.json')

    # All scripts are first grouped based on the #Dataspot tag. Error will occur when a script is not tagged or is
    # tagged with an unsupported type
    scripts = ScriptGrouper.group(scripts_path=scripts_path)

    # The relationships variable is a dictionary containing the object-name as key, and the object-sources represented
    # in a list, as the key's value
    relationships = RelationshipsDirector.build(scripts=scripts, parser_config_path=parser_config_path)

    # Dataspot offers the user the possibility to include their own relationships in the network analysis. This should
    # be a JSON file. An example of the format can be found in the examples directory.
    if manual:
        manual_relations_path = click.prompt('Please enter the full path to the file containing the manually determined'
                                             'relationships',
                                             default=os.path.join(os.path.abspath('../../'),
                                                                  'examples/manual_relationships_example.json'),
                                             type=click.Path(exists=True))

        # Open the JSON file from the path entered by the user
        f = open(manual_relations_path)
        manual_relationships = json.load(f)
        f.close()

        # Dataspot requires the JSON file to start with the key 'nodes'. The values behind the 'nodes' key will be
        # combined with the relationships found above.
        additional_relationships = manual_relationships['nodes']

        relationships = {**relationships, **additional_relationships}

    # Dataspot offers the user to include specific statistics on their objects. This can be results from other analysis
    # done on these objects, user statistics, etc. Dataspot combines these statistics with the general configuration
    # file. This information will be included in the visualization and in the report Dataspot generates. This should
    # be put in a JSON file. An example of the format can be found in the examples directory.
    if statistics:
        object_statistics_path = click.prompt('Please enter the full path to the file containing object statistics',
                                            default=os.path.join(os.path.abspath('../../'),
                                                                 'examples/object_statistics_example.json'),
                                            type=click.Path(exists=True))

        f = open(config_path)
        config = json.load(f)
        f.close()

        f = open(object_statistics_path)
        add_config = json.load(f)
        f.close()

        config = {**config, **add_config}

        text_file_writer = TextFileWriter()
        config_path = text_file_writer.write(scripts_path=scripts_path, data=config, title='dataspot_config',
                                             timestamp=True, extension='json')

    # All of the relationships Dataspot could find in the scripts will be put in a .txt file. This is convenient for
    # the user but is also necessary for the execution of the visualization part of Dataspot. This requires the
    # relationships to be present in a separate file.
    text_file_writer = TextFileWriter()
    relationships_path = text_file_writer.write(scripts_path=scripts_path, data=relationships, title='dataspot_',
                                                timestamp=True, extension='txt')

    # A command line call to the Dataspot server, which launces the network analysis/visualization
    path = os.path.abspath(os.path.join(os.path.dirname( __file__ ), '..', 'server/dataspot_server.py'))
    command = "python " + path + " -c " + config_path + " -r " + relationships_path

    os.system(command)


def log(string, color, font="slant", figlet=False):
    if colored:
        if not figlet:
            six.print_(colored(string, color))
        else:
            six.print_(colored(figlet_format(string, font=font), color))
    else:
        six.print_(string)


def main():
    log(string= "Dataspot", color='cyan', figlet=True)
    log("Dataspot is a script visualization tool which takes scripts that are used for data inserts \n"
        "and provide the user with full data lineage. \n\n"
        "Currently, Dataspot supports the following database scripting languages: \n\n"
        "[*] Teradata SQL \n", "white")
    log("Welcome to Dataspot", "blue")


if __name__ == "__main__":
    main()
    cli()

# TODO: Build in a config check. This should be a function that is called when using the cli. This function check the
#  Dataspot config file. When checked and approved, the check value should be passed (a simple 0/1 should do). Every
#  config component has a default check param of 0. When the check param is passed and this is 1, the checks in the
#  functions do not need to be completed anymore, which saves building time.

# TODO: Rebuild Dataspot config file so that all of it is based on dicts, with only values can be a list,
#  integer, string or dict (except for the groups).
