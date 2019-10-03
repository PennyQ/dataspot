# libraries

import pyodbc
import pandas as pd
import os
from dataspot.scripts.script_grouper import ScriptGrouper
from dataspot.relationships.relationships_director import RelationshipsDirector
from dataspot.relationships.writer.text_file_writer import TextFileWriter

# Steps:
# 1. send sql to teradata to query the first used table
# 2. use dataspot parser to loop and write to file
# 3. use dataspot visual to plot the data lineage structure (if possible)

# Extract sql statements from Teradata
def extract_sql(table_name):
    sql = "SHOW VIEW " + table_name

    conn_str = (
        r'DSN=TERADATA_SERVER_PROD;'  
    )

    with pyodbc.connect(conn_str) as conn:
        cur = conn.cursor()
        cur.execute(sql)
        scripts_path = os.path.join(os.path.abspath('../../'), 'examples/usercase1/')
        print("script_path", scripts_path)
        with open(scripts_path+table_name+".sql", "a", newline='') as f:
            f.write("#DATASPOT-TERADATA\n")
            for row in cur:
                print(row[0], file=f)


# Use Dataspot parser to build relationship
def build_relationship():
    # The parser configuration must exist in the main folder of Dataspot
    parser_config_path = os.path.abspath('../../dataspot/parser_config.json')

    # All scripts are first grouped based on the #Dataspot tag. Error will occur when a script is not tagged or is
    # tagged with an unsupported type
    scripts_path = os.path.join(os.path.abspath('../../'), 'examples/usercase1')
    print("script_path", scripts_path)
    scripts = ScriptGrouper.group(scripts_path=scripts_path)
    print("scripts", scripts)

    # The relationships variable is a dictionary containing the object-name as key, and the object-sources represented
    # in a list, as the key's value
    relationships = RelationshipsDirector.build(scripts=scripts, parser_config_path=parser_config_path)

    text_file_writer = TextFileWriter()
    relationships_path = text_file_writer.write(scripts_path=scripts_path, data=relationships, title='dataspot_',
                                                timestamp=True, extension='txt')
    return relationships


# Step 3: # 3. use dataspot visual to plot the data lineage structure (if possible)
# Initiation: pick only one table TODO: expand
extract_sql("mi_vm_bmd.vtrainset_wc_std")        # this works so far
build_relationship()

table_name = "mi_vm_bmd.vcustomer_engagement_scores"
while len(relationships) > 0:
    try:
        extract_sql(table_name)
    except pyodbc.Error as e:
        print(e)
        break

    relationships = build_relationship()
    try:
        table_name = relationships[table_name][0]
        print("new relationships", relationships)
        print("table name", table_name)
        print("---------------\n")
    except KeyError as e:
        print("keyerror as: ", e)
        print("relationships values", relationships.values())
        print("table_name", table_name)
        # when source table is also source for another table
        if table_name in [x for v in relationships.values() for x in v]:
            print("find in values")
            # continue  # TODO: wait for Patrick reply
            break
        else:
            print("this is the end!")
            break  
