import getopt
import sys


def parse_args(argv):
    # -c = path to the JSON configiration file
    # -r = path to the txt relationships file (normally generated from SQLDissector
    config_path = str()
    relationships_path = str()
    try:
        opts, args = getopt.getopt(argv, "hc:r:", ["cfile=", "rfile="])
    except getopt.GetoptError:
        sys.exit(2)
    for opt, arg in opts:
        if opt == '-h':
            sys.exit()
        elif opt in ("-c", "--cfile"):
            config_path = arg
        elif opt in ("-r", "--rfile"):
            relationships_path = arg

    return config_path, relationships_path