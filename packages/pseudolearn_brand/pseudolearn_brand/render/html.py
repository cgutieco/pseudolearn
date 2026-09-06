"""Filling of the brand guidelines template, whose figures come from the same geometry."""
import re

from .svg import render

TOKEN = re.compile(r"\{\{(svg|path):([a-z0-9-]+)\}\}")
PATHS = ("symbol", "route", "flag", "wordmark")


class TemplateError(ValueError):
    pass


def fill(composition, catalog, template):
    variants = {variant.name: variant for variant in catalog.variants}

    def replace(match):
        kind, name = match.group(1), match.group(2)
        if kind == "path":
            return _path(composition, name)
        if name not in variants:
            raise TemplateError(f"the template asks for the variant '{name}', which the catalog "
                                f"does not declare")
        return render(composition, variants[name], id_prefix=f"{name}-").body

    return TOKEN.sub(replace, template)


def _path(composition, name):
    if name not in PATHS:
        raise TemplateError(f"the template asks for the path '{name}', which is not one of {PATHS}")
    if name == "wordmark":
        return composition.wordmark.path
    return composition.path_for("" if name == "symbol" else name)


def literal_geometry(template):
    """Path data left in the template, which is geometry that stopped being generated."""
    return [match.group(0)[:60]
            for match in re.finditer(r'd="[^"]{120,}"', TOKEN.sub("", template))]
