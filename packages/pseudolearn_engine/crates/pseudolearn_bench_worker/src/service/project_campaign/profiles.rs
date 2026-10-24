use crate::service::project_campaign::datasets::{Dataset, SourceFile, package_wire};
use crate::service::project_campaign::shapes::constants;

pub const MODULE_COUNT: usize = 100;
pub const PAIR_COUNT: usize = 20;
const COLLISIONS: usize = 5;
const ENGLISH_KEYWORDS: [&str; COLLISIONS] = ["while", "for", "repeat", "write", "read"];
const SPANISH_KEYWORDS: [&str; COLLISIONS] = ["Mientras", "Para", "Repetir", "Escribir", "Leer"];

fn spanish_function(name: &str, constant: u64) -> String {
    format!(
        "Publico SubProceso {name}(n Como Entero) Como Entero\nRetornar n + {constant};\nFinSubProceso\n"
    )
}

fn english_function(name: &str, constant: u64) -> String {
    format!(
        "public subroutine {name}(n as integer) as integer\nreturn n + {constant};\nendSubroutine\n"
    )
}

fn entry_file(imports: &str, calls: &[String], constant: u64) -> SourceFile {
    let mut text = imports.to_owned();
    text.push_str("Algoritmo Principal\nDefinir total Como Entero;\ntotal <- 0;\n");
    for call in calls {
        text.push_str(&format!("total <- total + {call}(0);\n"));
    }
    text.push_str(&format!("Escribir total + {constant};\nFinAlgoritmo\n"));
    SourceFile {
        path: "app/main".to_owned(),
        text,
        profile: None,
    }
}

fn single_package(name: &str, files: Vec<SourceFile>, expected: u64) -> Dataset {
    Dataset {
        name: name.to_owned(),
        packages: vec![package_wire("app", "application", &["app/main"], &[])],
        files,
        entry: "app/main".to_owned(),
        expected_output: format!("{expected}\n"),
    }
}

pub fn modules_dataset(mixed: bool) -> Dataset {
    let values = constants(MODULE_COUNT + 1, 1_000);
    let mut imports = String::new();
    let mut calls = Vec::new();
    let mut files = Vec::new();
    for index in 1..=MODULE_COUNT {
        let constant = values.get(index).copied().unwrap_or(1);
        let name = format!("F{index}");
        imports.push_str(&format!("Importar app.m{index}.{name};\n"));
        calls.push(name.clone());
        let english = mixed && index % 2 == 1;
        files.push(SourceFile {
            path: format!("app/m{index}"),
            text: if english {
                english_function(&name, constant)
            } else {
                spanish_function(&name, constant)
            },
            profile: english.then_some("en"),
        });
    }
    let entry_constant = values.first().copied().unwrap_or(1);
    files.insert(0, entry_file(&imports, &calls, entry_constant));
    let name = if mixed {
        "modules-100-mixed"
    } else {
        "modules-100-control"
    };
    single_package(name, files, values.iter().sum())
}

struct Twin {
    name: String,
    alias: Option<String>,
}

fn twins(pair: usize, mixed: bool) -> (Twin, Twin) {
    let collides = mixed && pair < COLLISIONS;
    let spanish = Twin {
        name: if collides {
            ENGLISH_KEYWORDS
                .get(pair)
                .copied()
                .unwrap_or("while")
                .to_owned()
        } else {
            format!("D{pair}")
        },
        alias: None,
    };
    let english = Twin {
        name: if collides {
            SPANISH_KEYWORDS
                .get(pair)
                .copied()
                .unwrap_or("Mientras")
                .to_owned()
        } else {
            format!("E{pair}")
        },
        alias: collides.then(|| format!("Alias{pair}")),
    };
    (spanish, english)
}

struct PairParts {
    imports: String,
    calls: Vec<String>,
    files: Vec<SourceFile>,
}

fn pair_parts(pair: usize, constant: u64, mixed: bool) -> PairParts {
    let (spanish, english) = twins(pair, mixed);
    let mut imports = format!("Importar app.pe{pair}.{};\n", spanish.name);
    match &english.alias {
        Some(alias) => imports.push_str(&format!(
            "Importar app.pn{pair}.{} Como {alias};\n",
            english.name
        )),
        None => imports.push_str(&format!("Importar app.pn{pair}.{};\n", english.name)),
    }
    let local = english
        .alias
        .clone()
        .unwrap_or_else(|| english.name.clone());
    let english_text = if mixed {
        english_function(&english.name, constant)
    } else {
        spanish_function(&english.name, constant)
    };
    PairParts {
        imports,
        calls: vec![spanish.name.clone(), local],
        files: vec![
            SourceFile {
                path: format!("app/pe{pair}"),
                text: spanish_function(&spanish.name, constant),
                profile: None,
            },
            SourceFile {
                path: format!("app/pn{pair}"),
                text: english_text,
                profile: mixed.then_some("en"),
            },
        ],
    }
}

pub fn pairs_dataset(mixed: bool) -> Dataset {
    let values = constants(PAIR_COUNT + 1, 2_000);
    let mut imports = String::new();
    let mut calls = Vec::new();
    let mut files = Vec::new();
    for pair in 0..PAIR_COUNT {
        let constant = values.get(pair.saturating_add(1)).copied().unwrap_or(1);
        let parts = pair_parts(pair, constant, mixed);
        imports.push_str(&parts.imports);
        calls.extend(parts.calls);
        files.extend(parts.files);
    }
    let entry_constant = values.first().copied().unwrap_or(1);
    files.insert(0, entry_file(&imports, &calls, entry_constant));
    let doubled: u64 = values
        .iter()
        .skip(1)
        .map(|constant| constant.saturating_mul(2))
        .sum();
    let name = if mixed {
        "pairs-20-mixed"
    } else {
        "pairs-20-control"
    };
    single_package(name, files, doubled.saturating_add(entry_constant))
}
