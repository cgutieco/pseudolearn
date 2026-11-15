#![forbid(unsafe_code)]

use see_model::Corpus;
use std::collections::{BTreeMap, BTreeSet};

pub fn validate(corpus: &Corpus) -> Vec<String> {
    let versions: BTreeMap<_, _> = corpus
        .iter()
        .map(|specification| {
            (
                specification.metadata.id.as_str(),
                specification.metadata.version.as_str(),
            )
        })
        .collect();
    let mut errors = Vec::new();
    for specification in corpus {
        for dependency in &specification.metadata.depende_de {
            match versions.get(dependency.id.as_str()) {
                None => errors.push(format!("SEE-REFERENCE: missing {}", dependency.id)),
                Some(version) => check_range(&dependency.version, version, &mut errors),
            }
            if ![
                "usa",
                "refina",
                "restringe",
                "requiere",
                "verifica",
                "reemplaza",
            ]
            .contains(&dependency.tipo.as_str())
            {
                errors.push(format!(
                    "SEE-GRAPH: invalid dependency type {}",
                    dependency.tipo
                ));
            }
        }
    }
    if cyclic(corpus) {
        errors.push("SEE-CYCLE: cyclic dependencies".to_owned());
    }
    errors
}

fn check_range(range: &str, version: &str, errors: &mut Vec<String>) {
    let matches = semver::VersionReq::parse(range).and_then(|requirement| {
        semver::Version::parse(version).map(|version| requirement.matches(&version))
    });
    if !matches!(matches, Ok(true)) {
        errors.push(format!("SEE-RANGE: {version} does not satisfy {range}"));
    }
}

fn cyclic(corpus: &Corpus) -> bool {
    let mut remaining: BTreeSet<&str> = corpus
        .iter()
        .map(|specification| specification.metadata.id.as_str())
        .collect();
    loop {
        let ready: Vec<&str> = corpus
            .iter()
            .filter(|specification| {
                remaining.contains(specification.metadata.id.as_str())
                    && specification
                        .metadata
                        .depende_de
                        .iter()
                        .all(|dependency| !remaining.contains(dependency.id.as_str()))
            })
            .map(|specification| specification.metadata.id.as_str())
            .collect();
        if ready.is_empty() {
            return !remaining.is_empty();
        }
        for id in ready {
            remaining.remove(id);
        }
    }
}

pub fn impact(corpus: &Corpus, id: &str) -> Result<Vec<String>, String> {
    if !corpus
        .iter()
        .any(|specification| specification.metadata.id == id)
    {
        return Err(format!("Unknown specification: {id}"));
    }
    let mut affected = BTreeSet::from([id.to_owned()]);
    loop {
        let previous = affected.len();
        for specification in corpus {
            if specification
                .metadata
                .depende_de
                .iter()
                .any(|dependency| affected.contains(&dependency.id))
            {
                affected.insert(specification.metadata.id.clone());
            }
        }
        if affected.len() == previous {
            return Ok(affected.into_iter().collect());
        }
    }
}

pub fn render(corpus: &Corpus, focused: Option<&str>, dot: bool) -> Result<String, String> {
    let included = focused.map(|id| impact(corpus, id)).transpose()?;
    let mut output = if dot {
        "digraph specifications {\n".to_owned()
    } else {
        String::new()
    };
    for specification in corpus.iter().filter(|specification| {
        included
            .as_ref()
            .is_none_or(|included| included.contains(&specification.metadata.id))
    }) {
        let id = &specification.metadata.id;
        output.push_str(&if dot {
            format!("  \"{id}\";\n")
        } else {
            format!("{id}\n")
        });
        for dependency in &specification.metadata.depende_de {
            output.push_str(&if dot {
                format!(
                    "  \"{id}\" -> \"{}\" [label=\"{}\"];\n",
                    dependency.id, dependency.tipo
                )
            } else {
                format!(
                    "  {} {} {}\n",
                    dependency.tipo, dependency.id, dependency.version
                )
            });
        }
    }
    if dot {
        output.push_str("}\n");
    }
    Ok(output)
}
