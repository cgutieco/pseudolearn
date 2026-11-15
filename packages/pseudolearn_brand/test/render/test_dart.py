import unittest

from pseudolearn_brand.model import catalog, composition
from pseudolearn_brand.render import dart

SOURCE = """final class BrandMetricsTokens {
  static const double symbolStroke = 14.0;
  static const int symbolTurnCount = 6;
}
"""


class DeclaredTest(unittest.TestCase):
    def test_it_reads_doubles_and_integers_alike(self):
        self.assertEqual(dart.declared(SOURCE), {"symbolStroke": 14.0, "symbolTurnCount": 6.0})

    def test_a_file_with_no_constants_reads_empty(self):
        self.assertEqual(dart.declared("class Empty {}"), {})


class MismatchTest(unittest.TestCase):
    def setUp(self):
        self.catalog = catalog.load()
        self.composition = composition.build(self.catalog)

    def expected_source(self):
        lines = [f"  static const double {name} = {value!r};"
                 for name, value in dart.expected(self.composition, self.catalog).items()]
        return "final class BrandMetricsTokens {\n" + "\n".join(lines) + "\n}\n"

    def test_a_file_that_declares_every_derived_measure_passes(self):
        self.assertEqual(dart.mismatches(self.composition, self.catalog,
                                         self.expected_source()), [])

    def test_a_changed_measure_is_reported(self):
        drifted = self.expected_source().replace("symbolStroke = 14.0", "symbolStroke = 15.0")
        problems = dart.mismatches(self.composition, self.catalog, drifted)
        self.assertEqual(len(problems), 1)
        self.assertIn("symbolStroke", problems[0])

    def test_a_missing_measure_is_reported(self):
        problems = dart.mismatches(self.composition, self.catalog, "class Empty {}")
        self.assertEqual(len(problems), len(dart.expected(self.composition, self.catalog)))

    def test_measures_the_application_owns_are_left_alone(self):
        extra = self.expected_source().replace(
            "}\n", "  static const double symbolSizeHero = 56.0;\n}\n")
        self.assertEqual(dart.mismatches(self.composition, self.catalog, extra), [])


if __name__ == "__main__":
    unittest.main()
