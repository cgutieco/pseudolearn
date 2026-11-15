"""Location of the monorepo root, so no path in this package counts directories upwards."""
from pathlib import Path

MARKER = ".git"


class RepositoryNotFound(RuntimeError):
    pass


def root(start=None):
    current = Path(start or Path(__file__).resolve().parent)
    for candidate in [current, *current.parents]:
        if (candidate / MARKER).exists():
            return candidate
    raise RepositoryNotFound(f"no directory containing '{MARKER}' above {current}")
