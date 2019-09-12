import os
import sys
import json
from dataspot.visualization.visual_builder import VisualBuilder
from dataspot.visualization.visual_helper import VisualHelper
from dataspot.helper.parse_args import parse_args
from bokeh.server.server import Server


def modify_doc(doc):
    # Parse arguments in order to retrieve the path of the config_old file and the locations of the relationships to be
    # displayed
    argv = sys.argv[1:]
    config_path, relationships_path = parse_args(argv=argv)

    # open de files in de bovenstaande paden
    f = open(config_path)
    config = json.load(f)
    f.close()

    f = open(relationships_path)
    relationships = json.load(f)
    f.close()

    # Instantiate the visualization

    visualbuilder = VisualBuilder(config=config, relationships=relationships)

    # Setup the working document
    doc = VisualHelper.setup_doc(doc)

    # Setup the visualization

    visualbuilder.build()

    # Add the visualization to the working document
    doc.add_root(visualbuilder.get_visual())


server = Server({'/': modify_doc}, num_procs=1)
server.start()

if __name__ == '__main__':
    from bokeh.util.browser import view

    print('Opening Dataspot on http://localhost:5006/')

    server.io_loop.add_callback(view, "http://localhost:5006/")
    server.io_loop.start()