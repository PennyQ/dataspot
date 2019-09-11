#!/usr/bin/python
import os
import click
import json
import six
# import sys
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
    The command line interface (cli_old) guides the user through the set-up of their SQL script analysis.
    :param config_path: The path/filename of the JSON formatted config_old file
    :param scripts_path: The path where the scripts are located
    :param output_path: The path where the results should be stored
    :param visualization: A boolean operator indicating if the user wants to have the output visualized
    :param manual: A boolean operator indicating if the user wants to add relation which were defined manually.
                   Manually added relation should be put in a .txt file, following a dictionary format
    """

    # # # The recursions limit is set to 10,000. This is to ensure that there will be no RecursionError while dissecting
    # # # the scripts. Adjustments will be made to the Dissector to ensure a limit is not necessary
    # limit = 10000
    # sys.setrecursionlimit(limit)

    # A list with the specified locations for input & output will be used by the ScriptsDissector
    scripts = ScriptGrouper.group(scripts_path=scripts_path)
    relationships = RelationshipsDirector.build(scripts=scripts)

    if manual:
        manual_relations_path = click.prompt('Please enter the full path to the file containing the manually determined '
                                             'relationships',
                                             default=os.path.join(os.path.abspath('../../'), 'examples/clan_relationships_20190613_092909.json'),
                                             type=click.Path(exists=True))
        f = open(manual_relations_path)
        manual_relationships = json.load(f)
        f.close()

        additional_relationships = dict()
        for key,value in manual_relationships["nodes"].items():
            additional_relationships[key] = value

        relationships = {**relationships, **additional_relationships}

    if statistics:
        user_statistics_path = click.prompt('Please enter the full path to the file containing user statistics',
                                             default=os.path.join(os.path.abspath('../../'), 'examples/user_statistics.json'),
                                             type=click.Path(exists=True))
        f = open(config_path)
        config = json.load(f)
        f.close()

        f = open(user_statistics_path)
        add_config = json.load(f)
        f.close()

        config = {**config, **add_config}

        text_file_writer = TextFileWriter()
        config_path = text_file_writer.write(scripts_path=scripts_path, data=config, title='dataspot_config', timestamp=True, extension='json')

    text_file_writer = TextFileWriter()
    relationships_path = text_file_writer.write(scripts_path=scripts_path, data=relationships, title='dataspot_', timestamp=True, extension='txt')

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

