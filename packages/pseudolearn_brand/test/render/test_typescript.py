import unittest

from pseudolearn_brand.model import catalog, composition
from pseudolearn_brand.render import typescript


class ModuleTest(unittest.TestCase):
    def setUp(self):
        self.catalog = catalog.load()
        self.composition = composition.build(self.catalog)
        self.module = typescript.module(self.composition, self.catalog)

    def test_it_exports_the_view_box_and_the_path(self):
        self.assertIn("export const BRAND_SYMBOL_VIEW_BOX = '0 1 95 95';", self.module)
        self.assertIn("export const BRAND_SYMBOL_PATH =", self.module)

    def test_the_exported_path_is_the_geometry_and_not_a_copy_of_it(self):
        self.assertIn(self.composition.path_for(""), self.module)

    def test_it_carries_no_comment_the_web_verifier_would_reject(self):
        self.assertNotIn("//", self.module)
        self.assertNotIn("/*", self.module)

    def test_it_ends_in_a_single_newline(self):
        self.assertTrue(self.module.endswith(";\n"))
        self.assertFalse(self.module.endswith("\n\n"))


if __name__ == "__main__":
    unittest.main()
