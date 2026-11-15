import tempfile
import unittest
from pathlib import Path

from pseudolearn_brand.pipeline import repository


class RootTest(unittest.TestCase):
    def test_it_finds_the_monorepo_from_inside_the_package(self):
        self.assertTrue((repository.root() / "packages" / "pseudolearn_brand").is_dir())

    def test_it_climbs_from_a_nested_directory(self):
        nested = Path(__file__).resolve().parent
        self.assertEqual(repository.root(nested), repository.root())

    def test_a_tree_with_no_marker_is_reported(self):
        with tempfile.TemporaryDirectory() as directory:
            with self.assertRaises(repository.RepositoryNotFound):
                repository.root(directory)


if __name__ == "__main__":
    unittest.main()
