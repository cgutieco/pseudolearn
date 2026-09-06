"""Building and verification of every brand artefact declared in the catalog."""
from dataclasses import dataclass
from pathlib import Path

from ..model import catalog as catalog_module
from ..model import composition as composition_module
from ..model.catalog import PACKAGE_ROOT
from ..render import dart, html, svg, typescript
from ..model.typography import FONT_DIRECTORY
from .repository import root

OUTPUT_DIRECTORY = PACKAGE_ROOT / "out"


@dataclass(frozen=True)
class Artefact:
    path: Path
    content: str


@dataclass(frozen=True)
class Violation:
    target: str
    rule: str
    message: str


@dataclass(frozen=True)
class Plan:
    masters: tuple
    tracked: tuple
    verified: tuple


def plan(repository=None):
    repository = Path(repository) if repository else root()
    catalog = catalog_module.load()
    composition = composition_module.build(catalog)
    masters = tuple(Artefact(OUTPUT_DIRECTORY / variant.master,
                             svg.document(composition, variant))
                    for variant in catalog.variants)
    tracked = _tracked(repository, catalog, composition)
    verified = (catalog, composition, repository)
    return Plan(masters=masters, tracked=tracked, verified=verified)


def _tracked(repository, catalog, composition):
    artefacts = []
    for variant in catalog.variants:
        document = svg.document(composition, variant)
        for copy in variant.copies:
            artefacts.append(Artefact(repository / copy, document))
    symbol_module = catalog.emitters["typescript_symbol_path"]
    artefacts.append(Artefact(repository / symbol_module.path,
                              typescript.module(composition, catalog)))
    guidelines = catalog.emitters["guidelines"]
    template = (PACKAGE_ROOT / guidelines.template).read_text(encoding="utf-8")
    artefacts.append(Artefact(OUTPUT_DIRECTORY / guidelines.path,
                              html.fill(composition, catalog, template)))
    return tuple(artefacts)


def build(repository=None):
    prepared = plan(repository)
    written = []
    for artefact in prepared.masters + prepared.tracked:
        artefact.path.parent.mkdir(parents=True, exist_ok=True)
        artefact.path.write_text(artefact.content, encoding="utf-8")
        written.append(artefact.path)
    return written


def check(repository=None):
    prepared = plan(repository)
    catalog, composition, resolved = prepared.verified
    violations = []
    for artefact in prepared.tracked:
        if OUTPUT_DIRECTORY in artefact.path.parents:
            continue
        violations.extend(_compare(resolved, artefact))
    violations.extend(_check_dart(resolved, catalog, composition))
    violations.extend(_check_fonts(resolved, catalog))
    violations.extend(_check_template(catalog))
    return violations


def relative_path(repository, path):
    try:
        return str(path.relative_to(repository))
    except ValueError:
        return str(path)


def _compare(repository, artefact):
    name = relative_path(repository, artefact.path)
    rule = "BRAND-TS-STALE" if artefact.path.suffix == ".ts" else "BRAND-COPY-STALE"
    if not artefact.path.exists():
        return [Violation(name, rule, "the consumer is missing this generated artefact")]
    if artefact.path.read_text(encoding="utf-8") != artefact.content:
        return [Violation(name, rule, "the consumer holds a copy the engine no longer produces")]
    return []


def _check_dart(repository, catalog, composition):
    emitter = catalog.emitters["dart_brand_metrics"]
    path = repository / emitter.path
    name = relative_path(repository, path)
    if not path.exists():
        return [Violation(name, "BRAND-DART-DRIFT", "the file that redraws the brand is missing")]
    source = path.read_text(encoding="utf-8")
    return [Violation(name, "BRAND-DART-DRIFT", problem)
            for problem in dart.mismatches(composition, catalog, source)]


def _check_fonts(repository, catalog):
    mirror = repository / catalog.emitters["vendored_fonts"].path
    if not mirror.is_dir():
        return []
    violations = []
    for face in (catalog.typography.mono_face, catalog.typography.sans_face):
        original = mirror / face
        if not original.exists():
            continue
        if original.read_bytes() != (FONT_DIRECTORY / face).read_bytes():
            violations.append(Violation(
                relative_path(repository, FONT_DIRECTORY / face), "BRAND-FONT-DRIFT",
                "the vendored face differs from the one the application packages"))
    return violations


def _check_template(catalog):
    emitter = catalog.emitters["guidelines"]
    template = (PACKAGE_ROOT / emitter.template).read_text(encoding="utf-8")
    return [Violation(emitter.template, "BRAND-TEMPLATE-GEOMETRY",
                      f"path data written by hand instead of generated: {leftover}…")
            for leftover in html.literal_geometry(template)]
