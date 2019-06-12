Dataspot
==========

sqlanalyer is a commandline tool for visualizing the usage of tables in sql statements.

# Installation
sqlanalyzer currently supports Python 3.6

## Pre conditions
Note: It is assumed that you have installed python3 and the teradata client on your machine.
Note: In order to use pip you have to configure the abnamro proxy, see https://confluence.aws.abnamro.org/display/CLAN/Howto+configure+pip+using+the+abnamro+proxy


## Install of a release (windows)
```
$ pip install git+https://cbsp-abnamro.visualstudio.com/ClientAnalytics/_git/sqlanalyzer@1.0.0#egg=sqlanalyzer --upgrade
```

## Install of the master branch (windows)
```
$ pip install git+https://cbsp-abnamro.visualstudio.com/ClientAnalytics/_git/sqlanalyzer#egg=sqlanalyzer --upgrade
```


## Check that the installation worked

Simply run `sqlanalyzer -r`.


## Set-up configuration

sqlanalyzer takes a JSON formatted configuration file in order to customize the output and visualization.

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
