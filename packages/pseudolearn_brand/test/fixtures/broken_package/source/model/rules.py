import subprocess

from ..render import svg


def draw(first, second, third):
    # the name should have said this
    for a in first:
        for b in second:
            if a == b:
                return svg
    return subprocess
