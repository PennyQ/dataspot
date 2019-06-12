import unittest
from dataspot.scripts.script_grouper import ScriptGrouper


class TestScriptGrouper(unittest.TestCase):

    def setUp(self):
        self.__script_path = '/Users/patrickdehoon/PycharmProjects/Dataspot/tests/scripts/valid_scripts/'
        self.__script_path_invalid = '/Users/patrickdehoon/PycharmProjects/Dataspot/tests/scripts/invalid_scripts' \
                                     '/dataspot_invalid_script_test.sql'
        self.__grouper = {'TERADATA': ['/Users/patrickdehoon/PycharmProjects/Dataspot/tests/scripts/valid_scripts/'
                                       'dataspot_script_test.sql']}

    def test_grouper(self):
        script_grouper = ScriptGrouper()
        result = script_grouper.group(scripts_path=self.__script_path)
        self.assertEqual(self.__grouper, result)

    def test_validate(self):
        script_grouper = ScriptGrouper()
        with self.assertRaises(TypeError):
            script_grouper.validate(script=self.__script_path_invalid)

    def tearDown(self):
        pass


if __name__ == '__main__':
    unittest.main()