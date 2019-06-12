import unittest
from dataspot.relationships.teradata_dissector import TeradataDissector


class TestTeradataDissector(unittest.TestCase):

    def setUp(self):
        self.__script = '/Users/patrickdehoon/PycharmProjects/Dataspot/tests/scripts/valid_scripts/dataspot_script_test.sql'

    def test_create_relationships(self):
        script = self.__script
        teradata_dissector = TeradataDissector()
        result = teradata_dissector.create_relationships(script=script)
        print("test_create_relationships", result)

    def tearDown(self):
        pass


if __name__ == '__main__':
    unittest.main()