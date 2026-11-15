use pseudolearn_api::{AnalyzeRequest, TargetLanguage, equivalent_code, execute_analyze};
use serde_json::Value;
use std::collections::BTreeSet;

const PYTHON_BUILTINS: &[&str] = &[
    "abs",
    "aiter",
    "all",
    "anext",
    "any",
    "ascii",
    "bin",
    "bool",
    "breakpoint",
    "bytearray",
    "bytes",
    "callable",
    "chr",
    "classmethod",
    "compile",
    "complex",
    "delattr",
    "dict",
    "dir",
    "divmod",
    "enumerate",
    "eval",
    "exec",
    "exit",
    "filter",
    "float",
    "format",
    "frozenset",
    "getattr",
    "globals",
    "hasattr",
    "hash",
    "help",
    "hex",
    "id",
    "input",
    "int",
    "isinstance",
    "issubclass",
    "iter",
    "len",
    "list",
    "locals",
    "map",
    "max",
    "memoryview",
    "min",
    "next",
    "object",
    "oct",
    "open",
    "ord",
    "pow",
    "print",
    "property",
    "quit",
    "range",
    "repr",
    "reversed",
    "round",
    "set",
    "setattr",
    "slice",
    "sorted",
    "staticmethod",
    "str",
    "sum",
    "super",
    "tuple",
    "type",
    "vars",
    "zip",
];

fn python_code(program: &str) -> Option<String> {
    let request = AnalyzeRequest {
        program: program.to_owned(),
        profile: "es".to_owned(),
        source: None,
    };
    equivalent_code(&request, TargetLanguage::Python, Some(7))
        .get("code")
        .and_then(Value::as_str)
        .map(str::to_owned)
}

fn declarable(program: &str) -> bool {
    execute_analyze(&AnalyzeRequest {
        program: program.to_owned(),
        profile: "es".to_owned(),
        source: None,
    })
    .diagnostics
    .iter()
    .all(|diagnostic| diagnostic.severity != "error")
}

fn corpus_programs() -> Vec<String> {
    let path = concat!(
        env!("CARGO_MANIFEST_DIR"),
        "/../../../pseudolearn_spec/specifications/export.json"
    );
    let text = std::fs::read_to_string(path).unwrap_or_default();
    let corpus: Value = serde_json::from_str(&text).unwrap_or(Value::Null);
    let mut programs = Vec::new();
    collect_programs(&corpus, &mut programs);
    programs
}

fn collect_programs(value: &Value, programs: &mut Vec<String>) {
    match value {
        Value::Object(fields) => {
            if let Some(program) = fields
                .get("programas")
                .and_then(|programs| programs.get("es"))
                .and_then(Value::as_str)
            {
                programs.push(program.to_owned());
            }
            fields
                .values()
                .for_each(|child| collect_programs(child, programs));
        }
        Value::Array(items) => items
            .iter()
            .for_each(|child| collect_programs(child, programs)),
        _ => {}
    }
}

fn calls(code: &str, name: &str) -> bool {
    code.match_indices(&format!("{name}(")).any(|(start, _)| {
        code.get(..start)
            .and_then(|prefix| prefix.chars().next_back())
            .is_none_or(|previous| {
                !(previous.is_alphanumeric() || previous == '_' || previous == '.')
            })
    })
}

fn imported_names(code: &str) -> impl Iterator<Item = String> + '_ {
    code.lines()
        .filter_map(|line| {
            line.strip_prefix("import ")
                .or_else(|| line.split_once(" import ").map(|(_, names)| names))
        })
        .flat_map(|names| names.split(','))
        .map(|name| name.split(" as ").last().unwrap_or(name).trim().to_owned())
        .filter(|name| name.chars().all(|character| character.is_ascii_lowercase()))
}

#[test]
fn every_builtin_and_import_the_python_output_uses_is_renamed_in_user_code() {
    let mut used = BTreeSet::new();
    for code in corpus_programs()
        .iter()
        .filter_map(|program| python_code(program))
    {
        used.extend(
            PYTHON_BUILTINS
                .iter()
                .filter(|name| calls(&code, name))
                .map(|name| (*name).to_owned()),
        );
        used.extend(imported_names(&code));
    }
    assert!(used.contains("len") && used.contains("math"), "{used:?}");
    let mut checked = 0;
    for name in &used {
        let program = format!(
            "Algoritmo P\nDefinir {name} Como Entero <- 1;\nEscribir {name};\nFinAlgoritmo\n"
        );
        if !declarable(&program) {
            continue;
        }
        let code = python_code(&program).unwrap_or_default();
        assert!(
            code.contains(&format!("{name}_value = 1")),
            "{name}: {code}"
        );
        checked += 1;
    }
    assert!(checked >= 10, "{checked} of {used:?}");
}

#[test]
fn the_call_scanner_ignores_methods_and_longer_names() {
    assert!(calls("x = len(y)", "len"));
    assert!(!calls("x = y.len(z)", "len"));
    assert!(!calls("x = my_len(z)", "len"));
    assert!(!calls("", "len"));
}
