"""Mechanical rules of this package: declared layers, import direction and size limits."""
import ast
import io
import json
import sys
import tokenize
from pathlib import Path

PACKAGE_ROOT = Path(__file__).resolve().parent.parent


def rules(package_root=PACKAGE_ROOT):
    return json.loads((package_root / "architecture.json").read_text(encoding="utf-8"))


def source_files(configuration, package_root=PACKAGE_ROOT):
    root = package_root / configuration["source_root"]
    return sorted(path for path in root.rglob("*.py"))


def layer_of(configuration, path, package_root=PACKAGE_ROOT):
    root = package_root / configuration["source_root"]
    parts = path.relative_to(root).parts
    if len(parts) < 2:
        return None
    return next((layer["name"] for layer in configuration["layers"]
                 if layer["path"] == parts[0]), parts[0])


def violations(package_root=PACKAGE_ROOT):
    configuration = rules(package_root)
    found = list(_undeclared_layers(configuration, package_root))
    for path in source_files(configuration, package_root):
        source = path.read_text(encoding="utf-8")
        name = str(path.relative_to(package_root))
        found.extend(_inline_comments(name, source))
        found.extend(_size(configuration, name, source))
        found.extend(_imports(configuration, path, name, source, package_root))
    return found


def _undeclared_layers(configuration, package_root):
    root = package_root / configuration["source_root"]
    declared = {layer["path"] for layer in configuration["layers"]}
    present = {entry.name for entry in root.iterdir()
               if entry.is_dir() and not entry.name.startswith("__")}
    for missing in sorted(declared - present):
        yield (configuration["source_root"], "BRAND-LAYER-DECLARED",
               f"the rules declare the layer '{missing}', which has no directory")
    for extra in sorted(present - declared):
        yield (f"{configuration['source_root']}/{extra}", "BRAND-LAYER-DECLARED",
               "this directory is a layer the rules do not declare")


def _inline_comments(name, source):
    for token in tokenize.generate_tokens(io.StringIO(source).readline):
        if token.type == tokenize.COMMENT:
            yield (f"{name}:{token.start[0]}", "BRAND-NO-COMMENTS",
                   f"comment '{token.string[:50]}'; the name says the what and the README the why")


def _size(configuration, name, source):
    limits = configuration["size"]
    lines = source.splitlines()
    if len(lines) > limits["file_lines"]:
        yield (name, "BRAND-SIZE-FILE",
               f"{len(lines)} lines against a limit of {limits['file_lines']}")
    tree = ast.parse(source)
    for node in ast.walk(tree):
        if isinstance(node, (ast.FunctionDef, ast.AsyncFunctionDef)):
            yield from _function_size(limits, name, node)
    depth = _depth(tree)
    if depth > limits["nesting"]:
        yield (name, "BRAND-SIZE-NESTING",
               f"nesting of {depth} against a limit of {limits['nesting']}")


def _function_size(limits, name, node):
    length = (node.end_lineno or node.lineno) - node.lineno + 1
    if length > limits["function_lines"]:
        yield (f"{name}:{node.lineno}", "BRAND-SIZE-FUNCTION",
               f"'{node.name}' spans {length} lines against a limit of {limits['function_lines']}")
    positional = len(node.args.posonlyargs) + len(node.args.args)
    if positional > limits["positional_parameters"]:
        yield (f"{name}:{node.lineno}", "BRAND-SIZE-PARAMETERS",
               f"'{node.name}' takes {positional} positional parameters against a limit of "
               f"{limits['positional_parameters']}")


NESTING_NODES = (ast.If, ast.For, ast.While, ast.With, ast.Try)


def _depth(node, current=0):
    deepest = current
    for child in _children(node):
        step = current + 1 if isinstance(child, NESTING_NODES) else current
        deepest = max(deepest, _depth(child, step))
    return deepest


def _children(node):
    """An `elif` reads as one more branch of the same decision, never as one more level."""
    if isinstance(node, ast.If) and len(node.orelse) == 1 and isinstance(node.orelse[0], ast.If):
        return [*node.body, *ast.iter_child_nodes(node.orelse[0])]
    return list(ast.iter_child_nodes(node))


def _imports(configuration, path, name, source, package_root=PACKAGE_ROOT):
    layer = layer_of(configuration, path, package_root)
    allowed = next((set(entry["may_import"]) for entry in configuration["layers"]
                    if entry["name"] == layer), None)
    for node in ast.walk(ast.parse(source)):
        if isinstance(node, ast.Import):
            yield from _forbidden(configuration, name, node,
                                  [alias.name for alias in node.names])
        elif isinstance(node, ast.ImportFrom):
            yield from _forbidden(configuration, name, node, [node.module or ""])
            if allowed is not None:
                yield from _direction(name, node, layer, allowed)


def _forbidden(configuration, name, node, modules):
    for module in modules:
        root = module.split(".")[0]
        if root in configuration["forbidden_imports"]:
            yield (f"{name}:{node.lineno}", "BRAND-FORBIDDEN-IMPORT",
                   f"'{module}' is not available to this package")


def _direction(name, node, layer, allowed):
    if node.level != 2 or not node.module:
        return
    target = node.module.split(".")[0]
    if target != layer and target not in allowed:
        yield (f"{name}:{node.lineno}", "BRAND-LAYER-DIRECTION",
               f"the layer '{layer}' imports from '{target}', which its rules do not allow")


def main():
    found = violations()
    if not found:
        print("✔ brand limits")
        return 0
    print(f"✖ brand limits — {len(found)} violación(es)", file=sys.stderr)
    for target, rule, message in found:
        print(f"  {target}\n    [{rule}] {message}", file=sys.stderr)
    return 1


if __name__ == "__main__":
    sys.exit(main())
