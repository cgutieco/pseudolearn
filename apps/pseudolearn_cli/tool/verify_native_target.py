"""Builds the native acceptance programs for one target with pseudo and checks their observable behaviour."""

import functools
import hashlib
import http.server
import json
import os
import pathlib
import platform
import shutil
import struct
import subprocess
import sys
import tempfile
import threading

CLI_ROOT = pathlib.Path(__file__).resolve().parent.parent
MANIFEST = CLI_ROOT / "examples" / "native-acceptance" / "manifest.json"
SERVED = CLI_ROOT / "examples" / "native-acceptance" / "served"
EXPORT = CLI_ROOT.parent.parent / "packages" / "pseudolearn_spec" / "specifications" / "export.json"
WINDOWS_ENVIRONMENT = ("SystemRoot", "SYSTEMROOT", "windir")
LINKER_VERSION = "lld-23.1.5"
CACHE_ROOTS = {
    "Darwin": (("HOME", ("Library", "Caches")),),
    "Linux": (("XDG_CACHE_HOME", ()), ("HOME", (".cache",))),
    "Windows": (("LOCALAPPDATA", ()),),
}


class QuietHandler(http.server.SimpleHTTPRequestHandler):
    """Serves the acceptance files without writing access logs."""

    def log_message(self, *_):
        """Discards the access log line."""


def start_server():
    """Starts a loopback HTTP server for the served directory and returns its base URL."""
    handler = functools.partial(QuietHandler, directory=str(SERVED))
    server = http.server.ThreadingHTTPServer(("127.0.0.1", 0), handler)
    threading.Thread(target=server.serve_forever, daemon=True).start()
    return f"http://127.0.0.1:{server.server_address[1]}"


def corpus_case(reference):
    """Returns the program, inputs and expected output of one corpus case from the export."""
    exported = json.loads(EXPORT.read_text(encoding="utf-8"))
    for specification in exported["specifications"]:
        if specification["metadata"].get("id") != reference["specification"]:
            continue
        for block in specification["blocks"]:
            fields = block.get("fields", {})
            if fields.get("id") == reference["case"]:
                return (
                    fields["programas"][reference["profile"]],
                    "".join(f"{line}\n" for line in fields.get("entradas", [])),
                    fields["espera"]["salida"],
                )
    raise SystemExit(f"missing corpus case {reference}")


def program_parts(entry, base_url):
    """Returns the program text, standard input and expected output of a manifest entry."""
    if "corpus" in entry:
        return corpus_case(entry["corpus"])
    program = (CLI_ROOT / entry["program"]).read_text(encoding="utf-8")
    expected = (CLI_ROOT / entry["expected"]).read_text(encoding="utf-8")
    standard_input = f"{base_url}\n" if entry.get("input_from_server") else ""
    return program, standard_input, expected


def isolated_environment():
    """Returns the empty environment, keeping only what Windows needs to load system libraries."""
    if os.name != "nt":
        return {}
    return {name: os.environ[name] for name in WINDOWS_ENVIRONMENT if name in os.environ}


def pe_imports(path):
    """Returns the DLL names imported by a PE executable."""
    image = path.read_bytes()
    header = struct.unpack_from("<I", image, 0x3C)[0]
    sections = struct.unpack_from("<H", image, header + 6)[0]
    optional_size = struct.unpack_from("<H", image, header + 20)[0]
    optional = header + 24
    import_rva = struct.unpack_from("<I", image, optional + 120)[0]
    table = header + 24 + optional_size

    def offset_of(rva):
        for index in range(sections):
            base = table + index * 40
            size, address, _, raw = struct.unpack_from("<IIII", image, base + 8)
            if address <= rva < address + max(size, 1):
                return rva - address + raw
        return None

    names = []
    cursor = offset_of(import_rva) if import_rva else None
    while cursor is not None:
        name_rva = struct.unpack_from("<I", image, cursor + 12)[0]
        if name_rva == 0:
            break
        start = offset_of(name_rva)
        names.append(image[start:image.index(b"\0", start)].decode("ascii"))
        cursor += 20
    return names


def dependencies(path):
    """Returns the dynamic libraries an executable declares, as reported by the platform tool."""
    system = platform.system()
    if system == "Windows":
        return "\n".join(pe_imports(path))
    command = ["otool", "-L", str(path)] if system == "Darwin" else ["ldd", str(path)]
    finished = subprocess.run(command, capture_output=True, text=True, check=False)
    return finished.stdout + finished.stderr


def check_entry(context, entry):
    """Builds and runs one acceptance program and returns its verdict."""
    pseudo, target, logs, base_url = context
    program, standard_input, expected = program_parts(entry, base_url)
    work = pathlib.Path(tempfile.mkdtemp(prefix=f"pseudo-native-{entry['name']}-"))
    source = work / f"{entry['name']}.pseudo"
    source.write_text(program, encoding="utf-8")
    suffix = ".exe" if "windows" in target else ""
    executable = work / f"{entry['name']}{suffix}"
    build = subprocess.run(
        [pseudo, "build", "--target", target, "-o", str(executable), str(source)],
        capture_output=True, text=True, check=False,
    )
    (logs / f"{entry['name']}.build.log").write_text(build.stdout + build.stderr, encoding="utf-8")
    verdict = {"name": entry["name"], "build_exit": build.returncode}
    if build.returncode == 0:
        source.unlink()
        run_directory = work / "run"
        run_directory.mkdir()
        finished = subprocess.run(
            [str(executable)], input=standard_input.encode("utf-8"), capture_output=True,
            cwd=run_directory, env=isolated_environment(), check=False,
        )
        output = finished.stdout.decode("utf-8", "replace")
        errors = finished.stderr.decode("utf-8", "replace")
        (logs / f"{entry['name']}.stdout").write_text(output, encoding="utf-8")
        (logs / f"{entry['name']}.stderr").write_text(errors, encoding="utf-8")
        (logs / f"{entry['name']}.dependencies").write_text(dependencies(executable), encoding="utf-8")
        verdict.update({
            "exit_code": finished.returncode,
            "output_matches": output == expected,
            "errors_match": errors == entry.get("expected_errors", ""),
            "exit_matches": finished.returncode == entry["exit_code"],
        })
    verdict["passed"] = all(verdict.get(key) for key in ("output_matches", "errors_match", "exit_matches"))
    shutil.rmtree(work, ignore_errors=True)
    return verdict


def describe_linker(logs):
    """Writes the location, digest and dynamic libraries of the linker that pseudo downloaded."""
    lines = []
    for variable, suffix in CACHE_ROOTS.get(platform.system(), ()):
        if not os.environ.get(variable):
            continue
        directory = pathlib.Path(os.environ[variable]).joinpath(*suffix, "pseudolearn", "linker", LINKER_VERSION)
        for linker in sorted(directory.glob("lld*")):
            digest = hashlib.sha256(linker.read_bytes()).hexdigest()
            lines.append(f"{linker} {linker.stat().st_size} {digest}")
            lines.append(dependencies(linker))
        break
    (logs / "linker.txt").write_text("\n".join(lines) + "\n", encoding="utf-8")


def main():
    """Runs every manifest entry and writes the summary; exits with 1 when one fails."""
    pseudo, target, logs = sys.argv[1], sys.argv[2], pathlib.Path(sys.argv[3])
    logs.mkdir(parents=True, exist_ok=True)
    context = (pseudo, target, logs, start_server())
    verdicts = [check_entry(context, entry) for entry in json.loads(MANIFEST.read_text(encoding="utf-8"))]
    summary = {"target": target, "host": platform.platform(), "machine": platform.machine(), "programs": verdicts}
    (logs / "summary.json").write_text(json.dumps(summary, indent=2), encoding="utf-8")
    describe_linker(logs)
    print(json.dumps(summary, indent=2))
    sys.exit(0 if all(verdict["passed"] for verdict in verdicts) else 1)


if __name__ == "__main__":
    main()
