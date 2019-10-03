import unittest
from dataspot.network.node_calculator import NodeCalculator
from pprint import pprint


class TestNodeScoresNetworker(unittest.TestCase):

    def setUp(self):
        self.__relationships = {"test_db_2.example_table_b": ["test_db_4.example_table_a",
                                                              "golden_source.example_table_a"],
                                "test_db_1.example_table_b": ["test_db_2.example_table_c", "test_db_2.example_table_b"],
                                "test_db_2.example_table_a": ["test_db_3.example_table_a", "test_db_3.example_table_c",
                                                              "test_db_3.example_table_b"],
                                "test_db_1.example_table_a": ["test_db_1.example_table_b", "test_db_2.example_table_a",
                                                              "test_db_3.example_table_b"],
                                "test_db_4.example_table_a": ["golden_source.example_table_a",
                                                              "golden_source.example_table_b"]}
        self.__grouped_weights = {1: ['test_db_1.example_table_a', 'test_db_1.example_table_b'],
                                  2: ['test_db_2.example_table_b', 'test_db_2.example_table_c',
                                      'test_db_2.example_table_a'],
                                  3: ['test_db_3.example_table_a', 'test_db_3.example_table_b',
                                      'test_db_3.example_table_c'],
                                  4: ['test_db_4.example_table_a'],
                                  5: ['golden_source.example_table_a', 'golden_source.example_table_b']}
        self.__nodes = ['test_db_2.example_table_b', 'test_db_1.example_table_b', 'test_db_2.example_table_a',
                        'test_db_1.example_table_a', 'test_db_4.example_table_a', 'golden_source.example_table_a',
                        'test_db_2.example_table_c', 'test_db_3.example_table_a', 'test_db_3.example_table_c',
                        'test_db_3.example_table_b', 'golden_source.example_table_b']
        self.__golden_sources = ["golden_source.example_table_a", "golden_source.example_table_b"]
        self.__levels = {0: ['golden_source.example_table_b', 'golden_source.example_table_a'],
                         1: ['test_db_3.example_table_b',
                             'test_db_2.example_table_c',
                             'test_db_3.example_table_c',
                             'test_db_3.example_table_a'],
                         2: ['test_db_4.example_table_a', 'test_db_2.example_table_a'],
                         3: ['test_db_2.example_table_b'],
                         4: ['test_db_1.example_table_b'],
                         5: ['test_db_1.example_table_a']}

    def test_root_score(self):
        test = NodeCalculator.calculate_root_scores(relationships=self.__relationships,
                                                        grouped_weights=self.__grouped_weights,
                                                        levels=self.__levels)

        # test = NodeCalculator.calculate_levels(golden_sources=self.__golden_sources, nodes=self.__nodes,
        #                                                 relationships=self.__relationships)
        pprint(test)

    def test_usage_score(self):
        pass

    def tearDown(self):
        pass


"""
Scores:
Root Score:

test_db_1.example_table_a: 31
test_db_1.example_table_b: 18
test_db_2.example_table_a: 11
test_db_2.example_table_b: 16
test_db_2.example_table_c: 2
test_db_3.example_table_a: 3
test_db_3.example_table_b: 3
test_db_3.example_table_c: 3 
test_db_4.example_table_b: 12
test_db_4.example_table_c: 4
test_db_4.example_table_d: 4

"""
