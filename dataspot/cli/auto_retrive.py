# libraries

import pyodbc
import pandas as pd
import os
import collections

from dataspot.scripts.script_grouper import ScriptGrouper
from dataspot.relationships.relationships_director import RelationshipsDirector
from dataspot.relationships.writer.text_file_writer import TextFileWriter

FLAG_WRITE = True   # only extract_sql update this variable

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
        sql_file_path = scripts_path+table_name+".sql"
        if not os.path.exists(sql_file_path):
            print("write to file: ", sql_file_path)
            global FLAG_WRITE 
            FLAG_WRITE = True
            with open(sql_file_path, "a", newline='') as f:
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
    scripts = ScriptGrouper.group(scripts_path=scripts_path)

    # The relationships variable is a dictionary containing the object-name as key, and the object-sources represented
    # in a list, as the key's value
    relationships = RelationshipsDirector.build(scripts=scripts, parser_config_path=parser_config_path)

    text_file_writer = TextFileWriter()
    relationships_path = text_file_writer.write(scripts_path=scripts_path, data=relationships, title='dataspot_',
                                                timestamp=True, extension='txt')
    return relationships


def breadth_first_search(graph, root): 
    visited, queue = set(), collections.deque([root])
    while queue: 
        vertex = queue.popleft()
        print("popleft vertex", vertex)
        # # explore one node and update relationships
        # extract_sql(vertex)
        # graph = build_relationship()
        print("graph", graph)
        try:
            for neighbour in graph[vertex]: 
                if neighbour not in visited: 
                    visited.add(neighbour) 
                    queue.append(neighbour)
        except KeyError as e:
            print(e)
            continue
    return visited

if __name__ == '__main__':
    # Step 3: # 3. use dataspot visual to plot the data lineage structure (if possible)
    # Initiation: pick only one table TODO: expand
    train_table = "mi_vm_bmd.vtrainset_wc_std"  # root
    extract_sql(train_table)        
    relationships = build_relationship()

    while FLAG_WRITE == True:
        visited = breadth_first_search(relationships, train_table)
        print("visited", visited)
        for table_name in visited:
            FLAG_WRITE = False
            try:
                extract_sql(table_name)
            except pyodbc.Error as e:
                print(e)
                print("%s is table not view, end" % table_name )
                continue
            relationships = build_relationship()
            print("flag is ", FLAG_WRITE)
