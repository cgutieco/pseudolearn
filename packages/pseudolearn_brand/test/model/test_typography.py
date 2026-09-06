import unittest

from pseudolearn_brand.model import typography


class RunTest(unittest.TestCase):
    def test_a_run_returns_path_data_and_its_advance(self):
        drawn, advance = typography.run("IBMPlexMono-Medium.ttf", "Pseudo", 100.0, 0, 90.0)
        self.assertTrue(drawn.startswith("M"))
        self.assertAlmostEqual(advance, 360.0, places=6)

    def test_the_monospaced_advance_is_a_constant_step_per_glyph(self):
        _drawn, advance = typography.run("IBMPlexMono-Medium.ttf", "Pse", 100.0, 0, 90.0)
        self.assertAlmostEqual(advance, 180.0, places=6)

    def test_negative_tracking_shortens_the_run(self):
        _drawn, loose = typography.run("IBMPlexSans-Bold.ttf", "Learn", 100.0, 0, 90.0)
        _drawn, tight = typography.run("IBMPlexSans-Bold.ttf", "Learn", 100.0, 0, 90.0, -1.5)
        self.assertLess(tight, loose)

    def test_an_empty_run_draws_nothing(self):
        self.assertEqual(typography.run("IBMPlexSans-Bold.ttf", "", 100.0, 0, 90.0), ("", 0.0))

    def test_a_character_the_face_does_not_carry_is_reported(self):
        with self.assertRaises(KeyError):
            typography.run("IBMPlexSans-Bold.ttf", "漢", 100.0, 0, 90.0)

    def test_a_face_that_is_not_vendored_is_reported(self):
        with self.assertRaises(Exception):
            typography.run("NotAFace.ttf", "L", 100.0, 0, 90.0)


class InkBoundsTest(unittest.TestCase):
    def test_the_box_sits_above_the_baseline(self):
        left, top, right, bottom = typography.ink_bounds(
            "IBMPlexMono-Medium.ttf", "Pseudo", 100.0, 0, 90.0)
        self.assertLess(top, bottom)
        self.assertLess(left, right)
        self.assertAlmostEqual(top, 16.0, places=6)

    def test_an_empty_run_has_no_box(self):
        self.assertIsNone(typography.ink_bounds("IBMPlexSans-Bold.ttf", "", 100.0, 0, 90.0))


if __name__ == "__main__":
    unittest.main()
