"""The brand measures the Flutter app redraws, and the reading of the file that declares them."""
import re

CONSTANT = re.compile(r"static const (?:double|int) (\w+) = (-?[\d.]+);")
TOLERANCE = 1e-6


def expected(composition, catalog):
    symbol = catalog.symbol
    typography = catalog.typography
    size = typography.type_size
    word = composition.wordmark
    placement = catalog.placement
    lockups = catalog.lockups
    return {
        "symbolGrid": symbol.grid,
        "symbolStroke": symbol.stroke,
        "symbolRun": symbol.run,
        "symbolTerminalRadius": symbol.terminal_radius,
        "symbolPennant": symbol.pennant,
        "symbolPennantRadius": symbol.pennant_radius,
        "symbolStartX": symbol.start_x,
        "symbolStartY": symbol.start_y,
        "symbolTurnCount": float(symbol.turns),
        "wordmarkInkLeft": word.left / size,
        "wordmarkInkTop": word.top / size,
        "wordmarkInkWidth": word.width / size,
        "wordmarkInkHeight": word.height / size,
        "wordmarkCapTop": typography.cap_top / size,
        "wordmarkCapBaseline": typography.baseline / size,
        "wordmarkCapHeight": typography.cap_height / size,
        "wordmarkSeam": typography.seam / size,
        "wordmarkTracking": typography.sans_tracking / size,
        "lockupHorizontalPlate": lockups.horizontal.plate,
        "lockupHorizontalGap": lockups.horizontal.gap,
        "lockupVerticalPlate": lockups.vertical.plate,
        "lockupVerticalGap": lockups.vertical.gap,
        "lockupClearSpace": lockups.clear_space,
        "plateCornerRatio": placement.squircle,
        "plateInscribedWidth": placement.max_width,
        "plateInscribedHeight": placement.max_height,
    }


def declared(source):
    return {name: float(value) for name, value in CONSTANT.findall(source)}


def mismatches(composition, catalog, source):
    found = declared(source)
    problems = []
    for name, value in expected(composition, catalog).items():
        if name not in found:
            problems.append(f"{name} is not declared; the engine derives {value:.6g}")
        elif abs(found[name] - value) > TOLERANCE:
            problems.append(f"{name} declares {found[name]:.6g}; the engine derives {value:.6g}")
    return problems
