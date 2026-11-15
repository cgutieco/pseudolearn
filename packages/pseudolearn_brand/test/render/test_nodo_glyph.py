import unittest

from pseudolearn_brand.model import catalog
from pseudolearn_brand.render import nodo_glyph

PAINTER = """
static const double grid = 24;
canvas.drawCircle(const Offset(9, 15), 5, stroke);
canvas.drawCircle(const Offset(7.25, 14.5), 0.9, eyes);
canvas.drawCircle(const Offset(10.75, 14.5), 0.9, eyes);
..moveTo(9, 10)
..lineTo(9, 6.5)
..lineTo(13.5, 6.5);
canvas.translate(18, 6.5);
"""


class ModuleTest(unittest.TestCase):
    def setUp(self):
        self.catalog = catalog.load()
        self.module = nodo_glyph.module(self.catalog)

    def test_it_exports_the_grid_the_stroke_and_the_node(self):
        self.assertIn("export const NODO_GLYPH_GRID = 24;", self.module)
        self.assertIn("export const NODO_GLYPH_STROKE = 1.5;", self.module)
        self.assertIn("{ cx: 9, cy: 15, r: 5 }", self.module)

    def test_it_exports_both_eyes_on_one_line(self):
        self.assertIn("xs: [7.25, 10.75]", self.module)
        self.assertIn("y: 14.5", self.module)

    def test_it_derives_the_wire_and_the_sparkle_from_the_measures(self):
        self.assertIn("NODO_GLYPH_WIRE_PATH = 'M9 10V6.5H13.5';", self.module)
        self.assertIn("M0 -4Q0.6 -0.6 4 0Q0.6 0.6 0 4Q-0.6 0.6 -4 0Q-0.6 -0.6 0 -4Z", self.module)

    def test_it_carries_no_comment_the_web_verifier_would_reject(self):
        self.assertNotIn("//", self.module)
        self.assertNotIn("/*", self.module)

    def test_it_ends_in_a_single_newline(self):
        self.assertTrue(self.module.endswith(";\n"))
        self.assertFalse(self.module.endswith("\n\n"))


class PainterTest(unittest.TestCase):
    def setUp(self):
        self.catalog = catalog.load()

    def test_a_painter_with_every_literal_has_no_mismatch(self):
        self.assertEqual(nodo_glyph.mismatches(self.catalog, PAINTER), [])

    def test_a_moved_node_is_reported(self):
        drifted = PAINTER.replace("Offset(9, 15), 5", "Offset(9, 16), 5")
        problems = nodo_glyph.mismatches(self.catalog, drifted)
        self.assertEqual(len(problems), 1)
        self.assertIn("Offset(9, 15), 5", problems[0])

    def test_an_empty_painter_reports_every_literal(self):
        self.assertEqual(len(nodo_glyph.mismatches(self.catalog, "")),
                         len(nodo_glyph.painter_literals(self.catalog)))


if __name__ == "__main__":
    unittest.main()
