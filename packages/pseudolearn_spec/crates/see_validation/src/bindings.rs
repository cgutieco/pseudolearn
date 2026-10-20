use see_model::{Corpus, evidence::Conformance, field};

pub fn check(corpus: &Corpus, conformance: &Conformance) -> Vec<String> {
    if !["activo", "retirado"].contains(&conformance.estado.as_str()) {
        return vec!["SEE-SUBJECT-STATE: unknown subject state".to_owned()];
    }
    if conformance.estado == "retirado" {
        return Vec::new();
    }
    let mut errors = Vec::new();
    let mut seen = std::collections::BTreeSet::new();
    for binding in &conformance.vinculos {
        if !seen.insert(&binding.regla) {
            errors.push("SEE-BINDING: duplicate binding".to_owned());
        }
        if !valid_reference(corpus, &binding.regla) {
            errors.push(format!("SEE-BINDING: unresolved {}", binding.regla));
        }
        match binding.estado.as_str() {
            "cumple" => (),
            "exento"
                if binding
                    .justificacion
                    .as_ref()
                    .is_some_and(|reason| !reason.is_empty()) => {}
            "pendiente"
                if binding
                    .resuelve_en
                    .as_ref()
                    .is_some_and(|phase| !conformance.fases_cerradas.contains(phase)) => {}
            _ => errors.push(format!("SEE-BINDING: invalid status {}", binding.regla)),
        }
    }
    errors.extend(stable_bindings(corpus, conformance));

    errors
}

fn valid_reference(corpus: &Corpus, reference: &str) -> bool {
    corpus.iter().any(|specification| {
        let prefix = format!(
            "{}@{}",
            specification.metadata.id, specification.metadata.version
        );
        reference == prefix
            || specification.blocks.iter().any(|block| {
                block.kind == "regla" && reference == format!("{prefix}#{}", field(block, "id"))
            })
    })
}

fn stable_bindings(corpus: &Corpus, conformance: &Conformance) -> Vec<String> {
    let mut errors = Vec::new();
    for specification in corpus.iter().filter(|specification| {
        specification.metadata.estado == "estable"
            && specification.metadata.sujetos.contains(&conformance.sujeto)
    }) {
        for rule in specification
            .blocks
            .iter()
            .filter(|block| block.kind == "regla")
        {
            let reference = format!(
                "{}@{}#{}",
                specification.metadata.id,
                specification.metadata.version,
                field(rule, "id")
            );
            if !conformance
                .vinculos
                .iter()
                .any(|binding| binding.regla == reference)
            {
                errors.push(format!(
                    "SEE-BINDING: stable rule without binding {reference}"
                ));
            }
        }
    }
    errors
}
