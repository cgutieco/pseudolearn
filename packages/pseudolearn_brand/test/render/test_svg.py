import unittest
from pathlib import Path

from pseudolearn_brand.model import catalog, composition
from pseudolearn_brand.render import svg

FIXTURES = Path(__file__).resolve().parent.parent / "fixtures"


class DocumentTest(unittest.TestCase):
    def setUp(self):
        self.catalog = catalog.load()
        self.composition = composition.build(self.catalog)
        self.variants = {variant.name: variant for variant in self.catalog.variants}

    def document(self, name):
        return svg.document(self.composition, self.variants[name])

    def test_the_favicon_matches_the_recorded_document(self):
        self.assertEqual(self.document("favicon"),
                         (FIXTURES / "favicon.svg").read_text(encoding="utf-8"))

    def test_every_variant_declares_its_title_and_closes_its_document(self):
        for name, variant in self.variants.items():
            with self.subTest(variant=name):
                document = self.document(name)
                self.assertIn(f"<title>{variant.title}</title>", document)
                self.assertTrue(document.endswith("</svg>\n"))

    def test_only_the_recolourable_variants_carry_a_colour_attribute(self):
        self.assertIn('color="#0F4346"', self.document("symbol"))
        self.assertNotIn(' color="#', self.document("app-icon").splitlines()[1])

    def test_the_symbol_document_draws_the_geometry_with_no_transform(self):
        self.assertEqual(self.document("symbol").count("transform="), 0)

    def test_the_layers_share_one_transform_so_they_stay_in_register(self):
        route = svg.render(self.composition, self.variants["01-ruta"]).body
        flag = svg.render(self.composition, self.variants["02-bandera"]).body
        self.assertEqual(route.split("><")[0], flag.split("><")[0])

    def test_the_flat_icon_bleeds_and_the_favicon_rounds(self):
        self.assertNotIn("rx=", self.document("app-icon"))
        self.assertIn("rx=", self.document("favicon"))


class CardTest(unittest.TestCase):
    def setUp(self):
        self.catalog = catalog.load()
        self.composition = composition.build(self.catalog)
        self.variant = next(variant for variant in self.catalog.variants
                            if variant.composition == "card")
        self.document = svg.document(self.composition, self.variant)

    def test_the_card_declares_the_open_graph_canvas(self):
        self.assertIn('viewBox="0 0 1200 630"', self.document)

    def test_the_card_paints_the_ground_the_watermark_and_the_lockup(self):
        self.assertIn("url(#ground)", self.document)
        self.assertIn(f'opacity="{self.catalog.card.watermark_opacity:g}"', self.document)
        self.assertIn(self.composition.wordmark.path, self.document)

    def test_the_card_draws_no_text_so_no_font_is_needed_to_rasterize_it(self):
        self.assertNotIn("<text", self.document)

    def test_the_lockup_stays_inside_the_margins_of_the_canvas(self):
        layout = self.composition.lockup("horizontal")
        scale = self.variant.canvas * self.catalog.card.span / layout.width
        left = self.variant.canvas * self.catalog.card.margin
        self.assertLess(left + layout.width * scale, self.variant.canvas)
        self.assertLess(layout.height * scale, self.variant.canvas_height)


class FragmentTest(unittest.TestCase):
    def setUp(self):
        self.catalog = catalog.load()
        self.composition = composition.build(self.catalog)
        self.variants = {variant.name: variant for variant in self.catalog.variants}

    def test_a_prefix_namespaces_the_gradient_so_two_fragments_can_share_a_page(self):
        fragment = svg.render(self.composition, self.variants["app-icon"], id_prefix="app-icon-")
        self.assertIn('id="app-icon-ground"', fragment.body)
        self.assertIn("url(#app-icon-ground)", fragment.body)

    def test_without_a_prefix_the_gradient_keeps_its_declared_name(self):
        fragment = svg.render(self.composition, self.variants["app-icon"])
        self.assertIn('id="ground"', fragment.body)

    def test_an_unknown_composition_is_reported_and_not_drawn_blank(self):
        broken = self.variants["symbol"].__class__(
            name="broken", composition="hologram", master="broken.svg", title="broken")
        with self.assertRaises(KeyError):
            svg.render(self.composition, broken)


if __name__ == "__main__":
    unittest.main()
