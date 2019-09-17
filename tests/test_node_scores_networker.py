import unittest
from dataspot.network.nodes.node_scores_networker import NodeScoresNetworker
from dataspot.network.node_calculator import NodeCalculator


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

    def test_root_score(self):
        test = NodeCalculator.calculate_levels(golden_sources=self.__golden_sources,
                                                                             nodes=self.__nodes,
                                                                             relationships=self.__relationships)

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
