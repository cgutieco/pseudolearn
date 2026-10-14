use see_model::{Corpus, field};

pub const PROTOCOL_SPECIFICATION: &str = "PERF.PROTOCOL";

pub fn check(corpus: &Corpus) -> Vec<String> {
    let protocol_rules: Vec<String> = corpus
        .iter()
        .filter(|specification| specification.metadata.id == PROTOCOL_SPECIFICATION)
        .flat_map(|specification| &specification.blocks)
        .filter(|block| block.kind == "regla")
        .map(|rule| format!("{PROTOCOL_SPECIFICATION}#{}", field(rule, "id")))
        .collect();
    corpus
        .iter()
        .flat_map(|specification| &specification.blocks)
        .filter(|block| block.kind == "medicion")
        .filter(|measurement| {
            !protocol_rules
                .iter()
                .any(|rule| rule == field(measurement, "protocolo"))
        })
        .map(|measurement| {
            format!(
                "SEE-MEASUREMENT-PROTOCOL: {} cites {}",
                field(measurement, "id"),
                field(measurement, "protocolo")
            )
        })
        .collect()
}
