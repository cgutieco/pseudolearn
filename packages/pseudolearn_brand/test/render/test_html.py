import unittest

from pseudolearn_brand.model import catalog, composition
from pseudolearn_brand.render import html


class FillTest(unittest.TestCase):
    def setUp(self):
        self.catalog = catalog.load()
        self.composition = composition.build(self.catalog)

    def fill(self, template):
        return html.fill(self.composition, self.catalog, template)

    def test_a_variant_token_becomes_the_body_of_that_variant(self):
        filled = self.fill("<svg>{{svg:favicon}}</svg>")
        self.assertIn('id="favicon-ground"', filled)

    def test_a_path_token_becomes_path_data(self):
        self.assertIn(self.composition.path_for(""), self.fill('d="{{path:symbol}}"'))

    def test_the_route_and_the_flag_are_separately_addressable(self):
        self.assertNotEqual(self.fill("{{path:route}}"), self.fill("{{path:flag}}"))

    def test_a_template_with_no_token_comes_back_untouched(self):
        self.assertEqual(self.fill("<p>sin figuras</p>"), "<p>sin figuras</p>")

    def test_an_unknown_variant_is_reported(self):
        with self.assertRaises(html.TemplateError):
            self.fill("{{svg:hologram}}")

    def test_an_unknown_path_is_reported(self):
        with self.assertRaises(html.TemplateError):
            self.fill("{{path:hologram}}")

    def test_the_shipped_template_resolves_every_token(self):
        emitter = self.catalog.emitters["guidelines"]
        template = (catalog.PACKAGE_ROOT / emitter.template).read_text(encoding="utf-8")
        self.assertNotIn("{{", self.fill(template))


class LiteralGeometryTest(unittest.TestCase):
    def test_it_finds_path_data_written_by_hand(self):
        pasted = 'd="' + "M 10,79 H 36 A 7,7 0 0 1 43,86 V 86 " * 5 + '"'
        self.assertEqual(len(html.literal_geometry(pasted)), 1)

    def test_a_token_is_not_path_data(self):
        self.assertEqual(html.literal_geometry('d="{{path:symbol}}"'), [])

    def test_a_short_figure_of_its_own_is_left_alone(self):
        self.assertEqual(html.literal_geometry('<path d="M0 0h95M0 96h95"/>'), [])

    def test_the_shipped_template_holds_no_geometry(self):
        emitter = catalog.load().emitters["guidelines"]
        template = (catalog.PACKAGE_ROOT / emitter.template).read_text(encoding="utf-8")
        self.assertEqual(html.literal_geometry(template), [])


if __name__ == "__main__":
    unittest.main()
