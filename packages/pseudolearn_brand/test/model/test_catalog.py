import json
import tempfile
import unittest
from pathlib import Path

from pseudolearn_brand.model import catalog


def written(document):
    handle = tempfile.NamedTemporaryFile("w", suffix=".json", delete=False)
    json.dump(document, handle)
    handle.close()
    return Path(handle.name)


def valid_document():
    return json.loads(catalog.CATALOG_FILE.read_text(encoding="utf-8"))


class LoadTest(unittest.TestCase):
    def test_the_shipped_catalog_loads(self):
        loaded = catalog.load()
        self.assertEqual(len(loaded.variants), 12)
        self.assertEqual(loaded.typography.cap_height, 69.8)

    def test_every_declared_variant_has_a_master_path(self):
        self.assertTrue(all(variant.master for variant in catalog.load().variants))

    def test_the_inscribed_height_stays_inside_the_maskable_safe_circle(self):
        placement = catalog.load().placement
        self.assertLessEqual(placement.max_height, placement.maskable_ceiling)


class RejectionTest(unittest.TestCase):
    def test_an_inscribed_height_past_the_safe_circle_is_rejected(self):
        document = valid_document()
        document["placement"]["max_height"] = 0.9
        with self.assertRaises(catalog.CatalogError):
            catalog.load(written(document))

    def test_an_unknown_composition_is_rejected(self):
        document = valid_document()
        document["variants"][0]["composition"] = "hologram"
        with self.assertRaises(catalog.CatalogError):
            catalog.load(written(document))

    def test_a_duplicated_variant_name_is_rejected(self):
        document = valid_document()
        document["variants"].append(dict(document["variants"][0]))
        with self.assertRaises(catalog.CatalogError):
            catalog.load(written(document))

    def test_an_unknown_key_is_rejected_instead_of_ignored(self):
        document = valid_document()
        document["variants"][0]["colour"] = "#000000"
        with self.assertRaises(catalog.CatalogError):
            catalog.load(written(document))

    def test_a_lockup_without_orientation_is_rejected(self):
        document = valid_document()
        lockup = next(entry for entry in document["variants"] if entry["composition"] == "lockup")
        del lockup["orientation"]
        with self.assertRaises(catalog.CatalogError):
            catalog.load(written(document))

    def test_an_icon_without_a_gradient_is_rejected(self):
        document = valid_document()
        icon = next(entry for entry in document["variants"] if entry["composition"] == "icon")
        del icon["gradient_id"]
        with self.assertRaises(catalog.CatalogError):
            catalog.load(written(document))


if __name__ == "__main__":
    unittest.main()
