import shutil
import tempfile
import unittest
from pathlib import Path

from pseudolearn_brand.pipeline import artefacts


class PlanTest(unittest.TestCase):
    def setUp(self):
        self.plan = artefacts.plan()

    def test_it_plans_one_master_per_declared_variant(self):
        self.assertEqual(len(self.plan.masters), 13)

    def test_every_master_lands_in_the_ignored_output_directory(self):
        for artefact in self.plan.masters:
            with self.subTest(path=artefact.path.name):
                self.assertIn(artefacts.OUTPUT_DIRECTORY, artefact.path.parents)

    def test_it_plans_local_consumer_outputs_and_the_guidelines(self):
        outputs = {artefact.path.name for artefact in self.plan.tracked}
        self.assertEqual(outputs, {"favicon.svg", "pseudo-file.svg", "social-card.svg",
                                   "symbol-path.generated.ts", "brand.generated.ts", "guidelines.html"})


class CheckTest(unittest.TestCase):
    def test_the_repository_as_it_stands_passes(self):
        self.assertEqual(artefacts.check(), [])

    def test_a_consumer_copy_that_drifted_is_reported(self):
        with self.repository_copy() as copy:
            favicon = copy / "apps/pseudolearn_web/public/favicon.svg"
            favicon.parent.mkdir(parents=True, exist_ok=True)
            favicon.write_text("<svg/>", encoding="utf-8")
            rules = [violation.rule for violation in artefacts.check(copy)]
            self.assertIn("BRAND-COPY-STALE", rules)

    def test_a_drifted_extension_icon_is_reported(self):
        with self.repository_copy() as copy:
            icon = copy / "apps/pseudolearn_vscode/media/icons/pseudo-file.svg"
            icon.parent.mkdir(parents=True, exist_ok=True)
            icon.write_text("<svg/>", encoding="utf-8")
            violations = artefacts.check(copy)
            self.assertIn(("BRAND-COPY-STALE", "apps/pseudolearn_vscode/media/icons/pseudo-file.svg"),
                          [(violation.rule, violation.target) for violation in violations])

    def test_missing_consumer_outputs_are_left_for_the_build_step(self):
        with self.repository_copy() as copy:
            self.assertEqual(artefacts.check(copy), [])

    def test_a_generated_module_that_drifted_is_reported(self):
        with self.repository_copy() as copy:
            module = copy / "apps/pseudolearn_web/src/shared/ui/brand-mark/symbol-path.generated.ts"
            module.parent.mkdir(parents=True, exist_ok=True)
            module.write_text("export const BRAND_SYMBOL_PATH = 'M0 0';\n", encoding="utf-8")
            rules = [violation.rule for violation in artefacts.check(copy)]
            self.assertIn("BRAND-TS-STALE", rules)

    def test_a_store_media_module_that_drifted_is_reported(self):
        with self.repository_copy() as copy:
            module = copy / "packages/pseudolearn_store_media/src/compose/brand.generated.ts"
            module.parent.mkdir(parents=True, exist_ok=True)
            module.write_text("export const BRAND_INK = '#000000';\n", encoding="utf-8")
            rules = [violation.rule for violation in artefacts.check(copy)]
            self.assertIn("BRAND-TS-STALE", rules)

    def test_a_redrawn_measure_that_drifted_is_reported(self):
        with self.repository_copy() as copy:
            metrics = copy / ("apps/pseudolearn_app/lib/presentation/theme/tokens/"
                              "brand_metrics.dart")
            metrics.write_text(
                metrics.read_text(encoding="utf-8").replace("symbolStroke = 14.0",
                                                            "symbolStroke = 12.0"),
                encoding="utf-8")
            violations = artefacts.check(copy)
            self.assertEqual([violation.rule for violation in violations], ["BRAND-DART-DRIFT"])
            self.assertIn("symbolStroke", violations[0].message)

    def repository_copy(self):
        return _RepositoryCopy()


class _RepositoryCopy:
    def __enter__(self):
        self.directory = Path(tempfile.mkdtemp())
        source = artefacts.root()
        for relative in ("apps/pseudolearn_app/lib/presentation/theme/tokens/brand_metrics.dart",):
            target = self.directory / relative
            target.parent.mkdir(parents=True, exist_ok=True)
            shutil.copyfile(source / relative, target)
        return self.directory

    def __exit__(self, *_details):
        shutil.rmtree(self.directory, ignore_errors=True)
        return False


class BuildTest(unittest.TestCase):
    def test_building_twice_writes_the_same_bytes(self):
        first = {artefact.path: artefact.content for artefact in artefacts.plan().masters}
        second = {artefact.path: artefact.content for artefact in artefacts.plan().masters}
        self.assertEqual(first, second)


if __name__ == "__main__":
    unittest.main()
