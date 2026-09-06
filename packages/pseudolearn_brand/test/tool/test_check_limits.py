import importlib.util
import unittest
from pathlib import Path

PACKAGE_ROOT = Path(__file__).resolve().parents[2]
FIXTURE = PACKAGE_ROOT / "test" / "fixtures" / "broken_package"


def _load():
    specification = importlib.util.spec_from_file_location(
        "check_limits", PACKAGE_ROOT / "tool" / "check_limits.py")
    module = importlib.util.module_from_spec(specification)
    specification.loader.exec_module(module)
    return module


check_limits = _load()


def rules_reported(violations):
    return {rule for _target, rule, _message in violations}


class RealPackageTest(unittest.TestCase):
    def test_this_package_satisfies_its_own_rules(self):
        self.assertEqual(check_limits.violations(), [])

    def test_every_declared_layer_has_a_directory(self):
        configuration = check_limits.rules()
        for layer in configuration["layers"]:
            with self.subTest(layer=layer["name"]):
                self.assertTrue((PACKAGE_ROOT / configuration["source_root"] / layer["path"])
                                .is_dir())


class BrokenPackageTest(unittest.TestCase):
    def setUp(self):
        self.violations = check_limits.violations(FIXTURE)
        self.rules = rules_reported(self.violations)

    def test_it_rejects_an_import_that_climbs_to_a_layer_the_rules_forbid(self):
        self.assertIn("BRAND-LAYER-DIRECTION", self.rules)

    def test_it_rejects_an_import_the_package_may_not_use(self):
        self.assertIn("BRAND-FORBIDDEN-IMPORT", self.rules)

    def test_it_rejects_a_comment(self):
        self.assertIn("BRAND-NO-COMMENTS", self.rules)

    def test_it_rejects_a_function_past_its_line_budget(self):
        self.assertIn("BRAND-SIZE-FUNCTION", self.rules)

    def test_it_rejects_too_many_positional_parameters(self):
        self.assertIn("BRAND-SIZE-PARAMETERS", self.rules)

    def test_it_rejects_nesting_past_the_limit(self):
        self.assertIn("BRAND-SIZE-NESTING", self.rules)

    def test_every_violation_names_a_file_and_a_rule(self):
        for target, rule, message in self.violations:
            with self.subTest(rule=rule):
                self.assertTrue(target and rule and message)


if __name__ == "__main__":
    unittest.main()
