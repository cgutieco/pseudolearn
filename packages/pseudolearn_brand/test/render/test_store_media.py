import json
import re
import unittest

from pseudolearn_brand.model import catalog, composition
from pseudolearn_brand.render import store_media, svg, typescript


class StoreMediaModuleTest(unittest.TestCase):
    def setUp(self):
        self.catalog = catalog.load()
        self.composition = composition.build(self.catalog)
        self.module = store_media.module(self.composition, self.catalog)

    def test_it_starts_with_the_same_symbol_module_the_web_receives(self):
        self.assertTrue(self.module.startswith(typescript.module(self.composition, self.catalog)))

    def test_it_exports_the_palette_from_the_catalog(self):
        self.assertIn(f"export const BRAND_GROUND_TOP = '{self.catalog.palette.ground_top}';", self.module)
        self.assertIn(f"export const BRAND_DEEP = '{self.catalog.palette.deep}';", self.module)

    def test_each_lockup_is_the_engine_document_and_not_a_copy(self):
        variant = next(entry for entry in self.catalog.variants if entry.name == "lockup-horizontal-inverse")
        expected = json.dumps(svg.document(self.composition, variant).strip())
        self.assertIn(f"export const BRAND_LOCKUP_HORIZONTAL_INVERSE_SVG =\n  {expected};", self.module)

    def test_every_constant_is_declared_once(self):
        names = re.findall(r"export const (\w+)", self.module)
        self.assertEqual(len(names), len(set(names)))

    def test_it_carries_no_comment_the_package_verifier_would_reject(self):
        self.assertNotIn("//", self.module.replace("http://", ""))
        self.assertNotIn("/*", self.module)

    def test_it_ends_in_a_single_newline(self):
        self.assertTrue(self.module.endswith(";\n"))
        self.assertFalse(self.module.endswith("\n\n"))


if __name__ == "__main__":
    unittest.main()
