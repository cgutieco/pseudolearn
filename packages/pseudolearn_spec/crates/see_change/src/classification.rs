use see_model::{Specification, field};

pub fn classify(previous: &Specification, current: &Specification) -> Result<Vec<String>, String> {
    let mut classes = Vec::new();
    if previous.metadata.estado == "estable" && current.metadata.estado == "obsoleta" {
        classes.push("deprecacion".to_owned());
    }
    for block in &current.blocks {
        let original = previous
            .blocks
            .iter()
            .find(|original| field(original, "id") == field(block, "id"));
        match original {
            None => classes.push(
                if block.kind == "caso" {
                    "verificacion_anadida"
                } else {
                    "ampliacion_candidata"
                }
                .to_owned(),
            ),
            Some(original) if original != block => {
                classes.push(classify_block(original, block).to_owned())
            }
            Some(_) => (),
        }
    }
    complete(previous, current, &mut classes)?;
    classes.sort();
    classes.dedup();
    Ok(classes)
}

fn classify_block(previous: &see_model::Block, current: &see_model::Block) -> &'static str {
    if current.kind == "caso" && previous.fields.get("espera") != current.fields.get("espera") {
        return "cambio_significado_candidato";
    }
    if current.kind == "regla"
        && field(previous, "fuerza") != field(current, "fuerza")
        && field(current, "fuerza") == "DEBE"
    {
        return "restriccion_candidata";
    }
    "requiere_revision"
}

fn complete(
    previous: &Specification,
    current: &Specification,
    classes: &mut Vec<String>,
) -> Result<(), String> {
    if previous.blocks.iter().any(|block| {
        !current
            .blocks
            .iter()
            .any(|current| field(current, "id") == field(block, "id"))
    }) {
        classes.push("retirada".to_owned());
    }
    if previous.metadata.depende_de != current.metadata.depende_de {
        classes.push("requiere_revision".to_owned());
    }
    if classes.is_empty() && crate::hash(previous)? == crate::hash(current)? {
        classes.push("editorial".to_owned());
    }
    if classes.is_empty() {
        classes.push("requiere_revision".to_owned());
    }
    Ok(())
}
