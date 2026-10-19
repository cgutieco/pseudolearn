use see_model::{Corpus, field, strings};

pub const PROTOCOL_SPECIFICATION: &str = "PERF.PROTOCOL";

pub fn check(corpus: &Corpus) -> Vec<String> {
    let protocol_rules: Vec<String> = corpus
        .iter()
        .filter(|specification| specification.metadata.id == PROTOCOL_SPECIFICATION)
        .flat_map(|specification| &specification.blocks)
        .filter(|block| block.kind == "regla")
        .map(|rule| format!("{PROTOCOL_SPECIFICATION}#{}", field(rule, "id")))
        .collect();
    let mut errors = Vec::new();
    for specification in corpus {
        for measurement in specification
            .blocks
            .iter()
            .filter(|block| block.kind == "medicion")
        {
            if !protocol_rules
                .iter()
                .any(|rule| rule == field(measurement, "protocolo"))
            {
                errors.push(format!(
                    "SEE-MEASUREMENT-PROTOCOL: {} cites {}",
                    field(measurement, "id"),
                    field(measurement, "protocolo")
                ));
            }
            errors.extend(subject_scope(measurement, &specification.metadata.sujetos));
        }
    }
    errors
}

fn subject_scope(measurement: &see_model::Block, specification_subjects: &[String]) -> Vec<String> {
    let subjects = strings(measurement.fields.get("sujetos"));
    if subjects.is_empty() {
        return if specification_subjects.len() > 1 {
            vec![format!(
                "SEE-MEASUREMENT-SUBJECT: {} needs an explicit subject scope",
                field(measurement, "id")
            )]
        } else {
            Vec::new()
        };
    }
    subjects
        .into_iter()
        .filter(|subject| {
            !specification_subjects
                .iter()
                .any(|candidate| candidate == subject)
        })
        .map(|subject| {
            format!(
                "SEE-MEASUREMENT-SUBJECT: {} cites unknown subject {subject}",
                field(measurement, "id")
            )
        })
        .collect()
}
