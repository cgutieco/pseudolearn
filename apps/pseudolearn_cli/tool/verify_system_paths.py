"""Runs a VM program that writes and reads a file through every system path form of the host."""

import json
import os
import pathlib
import subprocess
import sys
import tempfile

PROGRAM = """SubProceso Probe(path Como Cadena) Como Resultado<Cadena, ErrorES>
Definir directory Como DirectorioCap <- Propagar SolicitarDirectorio(path);
Definir file Como ArchivoCap <- Propagar directory.Abrir("n.txt", "escritura");
Descartar file.EscribirTexto("dato");
Descartar file.Cerrar();
Definir reader Como ArchivoCap <- Propagar directory.Abrir("n.txt", "lectura");
Retornar reader.LeerTexto();
FinSubProceso
Algoritmo Main
Definir path Como Cadena;
Leer path;
Segun Probe(path) Hacer
Exito(value): Escribir value;
Error(problem): Escribir problem.Codigo;
FinSegun
FinAlgoritmo
"""


def path_forms(work):
    """Returns the named path texts that must reach the same directory on this host."""
    native = str(work / "target")
    forms = {"native": native, "relative": "target"}
    if os.name == "nt":
        forms["forward-slash"] = native.replace("\\", "/")
        forms["verbatim"] = "\\\\?\\" + native
        forms["relative-backslash"] = "target\\inner"
    else:
        forms["relative-nested"] = "target/inner"
    return forms


def check_form(pseudo, work, name, text):
    """Runs the program with one path form and returns its verdict."""
    finished = subprocess.run(
        [pseudo, "run", str(work / "probe.pseudo")], input=f"{text}\n".encode("utf-8"),
        capture_output=True, cwd=work, check=False,
    )
    output = finished.stdout.decode("utf-8", "replace")
    return {"form": name, "path": text, "exit_code": finished.returncode, "output": output,
            "passed": finished.returncode == 0 and output == "dato\n"}


def main():
    """Checks every path form and exits with 1 when one of them fails."""
    pseudo = str(pathlib.Path(sys.argv[1]).resolve())
    work = pathlib.Path(tempfile.mkdtemp(prefix="pseudo system paths "))
    (work / "target" / "inner").mkdir(parents=True)
    (work / "probe.pseudo").write_text(PROGRAM, encoding="utf-8")
    verdicts = [check_form(pseudo, work, name, text) for name, text in path_forms(work).items()]
    missing = check_form(pseudo, work, "missing", str(work / "absent"))
    verdicts.append({**missing, "passed": missing["exit_code"] == 0 and missing["output"] not in ("", "dato\n")})
    summary = {"os": os.name, "work": str(work), "forms": verdicts}
    print(json.dumps(summary, indent=2))
    sys.exit(0 if all(verdict["passed"] for verdict in verdicts) else 1)


if __name__ == "__main__":
    main()
