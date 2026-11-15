use reference_model::{AssertionSource, ProgramView, StructureCheck};

pub fn structure_problems(check: &StructureCheck) -> Vec<String> {
    let view = match &check.view {
        Ok(view) => view,
        Err(reason) => {
            return vec![format!(
                "the structural assertions cannot be checked against the reference: {reason}"
            )];
        }
    };
    check
        .assertions
        .iter()
        .filter(|assertion| !holds(assertion, view))
        .map(|assertion| {
            format!(
                "the reference does not satisfy the assertion `{}` {:?}",
                assertion.kind, assertion.fields
            )
        })
        .collect()
}

fn holds(assertion: &AssertionSource, view: &ProgramView) -> bool {
    let fields: Vec<&str> = assertion.fields.iter().map(String::as_str).collect();
    match (assertion.kind.as_str(), fields.as_slice()) {
        ("contiene", [construct]) => view.occurrences(construct) > 0,
        ("no-contiene", [construct]) => view.occurrences(construct) == 0,
        ("repite-como-mucho", [construct, maximum]) => maximum
            .parse::<usize>()
            .is_ok_and(|limit| view.occurrences(construct) <= limit),
        ("declara-subprograma", [name, arity]) => arity.parse::<usize>().is_ok_and(|expected| {
            view.subprograms
                .iter()
                .any(|found| found.name == *name && found.arity == expected)
        }),
        ("declara-miembro", [class, member, visibility]) => view.members.iter().any(|found| {
            found.class == *class
                && found.name == *member
                && visibility_word(&found.visibility) == *visibility
        }),
        _ => false,
    }
}

fn visibility_word(visibility: &str) -> &str {
    match visibility {
        "public" => "publico",
        "private" => "privado",
        other => other,
    }
}
