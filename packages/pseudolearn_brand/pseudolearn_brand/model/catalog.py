"""Typed reading of the brand catalog, with the invariants a variant must satisfy."""
import json
import math
from dataclasses import dataclass, field
from pathlib import Path

from .geometry import SymbolGeometry

PACKAGE_ROOT = Path(__file__).resolve().parents[2]
CATALOG_FILE = PACKAGE_ROOT / "brand.json"

COMPOSITIONS = ("symbol", "wordmark", "lockup", "icon", "layer", "ground", "mark")
LAYERS = ("route", "flag")
ORIENTATIONS = ("horizontal", "vertical")


class CatalogError(ValueError):
    pass


@dataclass(frozen=True)
class Typography:
    mono_face: str
    sans_face: str
    mono_text: str
    sans_text: str
    type_size: float
    baseline: float
    cap_top: float
    sans_tracking: float
    seam: float

    @property
    def cap_height(self):
        return self.baseline - self.cap_top


@dataclass(frozen=True)
class Palette:
    ground_top: str
    ground_bottom: str
    ink: str
    deep: str


@dataclass(frozen=True)
class Placement:
    max_width: float
    max_height: float
    maskable_safe_circle: float
    squircle: float

    @property
    def maskable_ceiling(self):
        return self.maskable_safe_circle / math.sqrt(2)


@dataclass(frozen=True)
class LockupRatios:
    plate: float
    gap: float


@dataclass(frozen=True)
class Lockups:
    horizontal: LockupRatios
    vertical: LockupRatios
    clear_space: float

    def by_orientation(self, orientation):
        return self.horizontal if orientation == "horizontal" else self.vertical


@dataclass(frozen=True)
class Variant:
    name: str
    composition: str
    master: str
    title: str
    ink: str = ""
    color_attribute: str = ""
    gradient_id: str = ""
    orientation: str = ""
    layer: str = ""
    canvas: float = 0.0
    visible: float = 0.0
    rounded: bool = False
    copies: tuple = ()


@dataclass(frozen=True)
class Emitter:
    name: str
    path: str
    mode: str
    template: str = ""


@dataclass(frozen=True)
class Catalog:
    symbol: SymbolGeometry
    typography: Typography
    palette: Palette
    placement: Placement
    lockups: Lockups
    variants: tuple
    emitters: dict = field(default_factory=dict)


def load(catalog_file=CATALOG_FILE):
    document = json.loads(Path(catalog_file).read_text(encoding="utf-8"))
    catalog = Catalog(
        symbol=SymbolGeometry(**document["symbol"]),
        typography=Typography(**document["typography"]),
        palette=Palette(**document["palette"]),
        placement=Placement(**document["placement"]),
        lockups=Lockups(
            horizontal=LockupRatios(**document["lockups"]["horizontal"]),
            vertical=LockupRatios(**document["lockups"]["vertical"]),
            clear_space=document["lockups"]["clear_space"]),
        variants=tuple(_variant(entry) for entry in document["variants"]),
        emitters={name: Emitter(name=name, **entry)
                  for name, entry in document["emitters"].items()})
    _validate(catalog)
    return catalog


def _variant(entry):
    unknown = set(entry) - set(Variant.__dataclass_fields__)
    if unknown:
        raise CatalogError(f"variant '{entry.get('name')}' declares unknown keys: {sorted(unknown)}")
    entry = dict(entry)
    entry["copies"] = tuple(entry.get("copies", ()))
    return Variant(**entry)


def _validate(catalog):
    if catalog.placement.max_height > catalog.placement.maskable_ceiling:
        raise CatalogError(
            f"max_height {catalog.placement.max_height} leaves the maskable safe circle, "
            f"whose ceiling for a square mark is {catalog.placement.maskable_ceiling:.4f}")
    names = [variant.name for variant in catalog.variants]
    duplicates = sorted({name for name in names if names.count(name) > 1})
    if duplicates:
        raise CatalogError(f"duplicated variant names: {duplicates}")
    for variant in catalog.variants:
        _validate_variant(variant)


def _validate_variant(variant):
    if variant.composition not in COMPOSITIONS:
        raise CatalogError(f"variant '{variant.name}' declares unknown composition "
                           f"'{variant.composition}'")
    if variant.composition == "lockup" and variant.orientation not in ORIENTATIONS:
        raise CatalogError(f"lockup '{variant.name}' needs an orientation of {ORIENTATIONS}")
    if variant.composition == "layer" and variant.layer not in LAYERS:
        raise CatalogError(f"layer '{variant.name}' needs a layer of {LAYERS}")
    if variant.composition in ("icon", "layer", "ground", "mark") and not variant.canvas:
        raise CatalogError(f"variant '{variant.name}' needs a canvas")
    if variant.composition in ("icon", "layer", "mark") and not variant.visible:
        raise CatalogError(f"variant '{variant.name}' needs a visible side")
    if variant.composition in ("lockup", "icon", "ground") and not variant.gradient_id:
        raise CatalogError(f"variant '{variant.name}' needs a gradient id")
