Dataspot
==========

Dataspot is a commandline tool for visualizing the usage of tables in amongst other, sql statements.

# Installation
Dataspot currently supports Python 3.6

## Pre conditions


## Install of a release (windows)


## Install of the master branch (windows)



## Check that the installation worked

Simply run `Dataspot -r`.


## Set-up configuration

Dataspot takes a JSON formatted configuration file in order to customize the output and visualization.

The following keys are accepted:
<pre>
--categories  
   --{category_name}  
      --args/tables  
      --legend_name  
      --color  
      --weights/weights_all
</pre>

categories: Specify the names of the categories you want to divide your tables in. There is no limit on how many 
categories you can make.

args/tables: You can specify to identify tables basedNot optionable on either the explicit name (tables) or based on an argument. 
The latter used when executing a find function. Both should be placed in a list.

legend_name: Specify the name you want to have displayed in the legend for this category.

color: Specify the hexadecimal color you want to use in the visualization for this category.

weighths/weighths_all: You can choose to specify the weight of the table on an individual basis (weighths) or on a 
general basis (weighths_all). In the former, the weighths are numbers and are the keys in a dictionary. The tables
belonging to this weight should be put in a list.
