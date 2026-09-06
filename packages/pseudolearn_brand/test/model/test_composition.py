import unittest

from pseudolearn_brand.model import catalog, composition


class WordmarkTest(unittest.TestCase):
    def setUp(self):
        self.catalog = catalog.load()
        self.composition = composition.build(self.catalog)

    def test_the_ink_box_is_the_master_vector_box(self):
        word = self.composition.wordmark
        self.assertAlmostEqual(word.left, 8.4, places=6)
        self.assertAlmostEqual(word.top, 16.0, places=6)
        self.assertAlmostEqual(word.width, 598.4, places=6)
        self.assertAlmostEqual(word.height, 75.2, places=6)

    def test_the_seam_pulls_the_sans_half_towards_the_mono_half(self):
        loose = catalog.load()
        object.__setattr__(loose.typography, "seam", 0.0)
        self.assertGreater(composition.build(loose).wordmark.width,
                           self.composition.wordmark.width)


class LockupTest(unittest.TestCase):
    def setUp(self):
        self.composition = composition.build(catalog.load())

    def test_the_horizontal_layout_matches_the_master_vector(self):
        layout = self.composition.lockup("horizontal")
        self.assertAlmostEqual(layout.width, 749.866, places=3)
        self.assertAlmostEqual(layout.height, 122.150, places=3)
        self.assertAlmostEqual(layout.plate_side, 122.150, places=3)
        self.assertAlmostEqual(layout.wordmark_dx, 151.466, places=3)
        self.assertAlmostEqual(layout.wordmark_dy, 21.975, places=3)

    def test_the_vertical_layout_matches_the_master_vector(self):
        layout = self.composition.lockup("vertical")
        self.assertAlmostEqual(layout.width, 598.400, places=3)
        self.assertAlmostEqual(layout.height, 292.126, places=3)
        self.assertAlmostEqual(layout.plate_side, 167.520, places=3)
        self.assertAlmostEqual(layout.plate_x, 215.440, places=3)
        self.assertAlmostEqual(layout.wordmark_dy, 216.926, places=3)

    def test_the_plate_is_centred_on_the_cap_line_and_not_on_the_ink_box(self):
        layout = self.composition.lockup("horizontal")
        self.assertAlmostEqual(layout.plate_y + layout.plate_side / 2,
                               self.composition.cap_center, places=6)

    def test_the_vertical_plate_is_centred_on_the_wordmark(self):
        layout = self.composition.lockup("vertical")
        self.assertAlmostEqual(layout.plate_x + layout.plate_side / 2,
                               self.composition.wordmark.width / 2, places=6)


class PlacementTest(unittest.TestCase):
    def setUp(self):
        self.composition = composition.build(catalog.load())

    def test_a_square_mark_is_bound_by_the_height_limit(self):
        placement = self.composition.catalog.placement
        self.assertAlmostEqual(self.composition.scale_for(1000.0),
                               1000.0 * placement.max_height / 95.0, places=9)

    def test_the_placement_centres_the_ink_box_on_the_given_point(self):
        left, top, width, height = self.composition.symbol_box
        x, y, scale = self.composition.placement_transform(1024.0, 512.0, 512.0)
        self.assertAlmostEqual(x + (left + width / 2) * scale, 512.0, places=6)
        self.assertAlmostEqual(y + (top + height / 2) * scale, 512.0, places=6)

    def test_the_scale_is_proportional_to_the_side(self):
        self.assertAlmostEqual(self.composition.scale_for(200.0),
                               2 * self.composition.scale_for(100.0), places=9)

    def test_a_side_of_zero_places_nothing(self):
        self.assertEqual(self.composition.scale_for(0.0), 0.0)


if __name__ == "__main__":
    unittest.main()
