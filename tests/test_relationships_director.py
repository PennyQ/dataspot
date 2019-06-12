import unittest
from dataspot.relationships.relationships_director import RelationshipsDirector


class TestRelationshipsDirector(unittest.TestCase):

    def setUp(self):
        self.__scripts = {'TERADATA': ['/Users/patrickdehoon/PycharmProjects/Dataspot/tests/scripts/valid_scripts/'
                                       'dataspot_script_test.sql']}
        self.__invalid_script = {'ORACLE': ['/Users/patrickdehoon/PycharmProjects/Dataspot/tests/scripts/valid_scripts/'
                                       'dataspot_script_test.sql']}

    def test_create_relationships(self):
        scripts = self.__scripts
        relationships_director = RelationshipsDirector()
        result = relationships_director.create_relationships(scripts=scripts)
        print("test_create_relationships", result)

    def test_invalid_script(self):
        scripts = self.__invalid_script
        relationships_director = RelationshipsDirector()
        with self.assertRaises(TypeError):
            relationships_director.create_relationships(scripts=scripts)

    def tearDown(self):
        pass


if __name__ == '__main__':
    unittest.main()