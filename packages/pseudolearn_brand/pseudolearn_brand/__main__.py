"""Command line of the brand engine: build every artefact, or verify the ones that are tracked."""
import sys

from .model.catalog import CatalogError
from .pipeline import artefacts
from .render.html import TemplateError


def main(arguments):
    command = arguments[0] if arguments else "build"
    if command == "build":
        return _build()
    if command == "check":
        return _check()
    print(f"unknown command '{command}'; expected 'build' or 'check'", file=sys.stderr)
    return 2


def _build():
    try:
        written = artefacts.build()
    except (CatalogError, TemplateError) as error:
        print(f"✖ brand build — {error}", file=sys.stderr)
        return 1
    repository = artefacts.root()
    for path in written:
        print(artefacts.relative_path(repository, path))
    print(f"✔ brand build — {len(written)} artefacts")
    return 0


def _check():
    try:
        violations = artefacts.check()
    except (CatalogError, TemplateError) as error:
        print(f"✖ brand check — {error}", file=sys.stderr)
        return 1
    if not violations:
        print("✔ brand check")
        return 0
    print(f"✖ brand check — {len(violations)} violación(es)", file=sys.stderr)
    for violation in violations:
        print(f"  {violation.target}\n    [{violation.rule}] {violation.message}", file=sys.stderr)
    return 1


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
