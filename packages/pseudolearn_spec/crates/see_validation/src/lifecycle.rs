use see_model::{Specification, contract::Lock, field};

pub fn check(specification: &Specification, lock: &Lock) -> Vec<String> {
    let metadata = &specification.metadata;
    let mut errors = Vec::new();
    if ![
        "borrador",
        "propuesta",
        "experimental",
        "estable",
        "obsoleta",
        "retirada",
        "rechazada",
    ]
    .contains(&metadata.estado.as_str())
    {
        errors.push("SEE-STATE: unknown lifecycle state".to_owned());
    }
    errors.extend(stability(specification));
    if metadata.id.starts_with("LANG.") && !metadata.edicion.contains_key("introducida_en") {
        errors.push("SEE-SCHEMA: language edition required".to_owned());
    }
    if let Some(previous) = lock.specifications.get(&metadata.id) {
        check_previous(specification, previous, &mut errors);
    }
    errors
}

fn check_previous(
    specification: &Specification,
    previous: &see_model::contract::Anchor,
    errors: &mut Vec<String>,
) {
    let metadata = &specification.metadata;
    if !transition(&previous.state, &metadata.estado) {
        errors.push("SEE-STATE: invalid lifecycle transition".to_owned());
    }
    check_elements(specification, previous, errors);
    if see_change::VERSIONING_FROZEN {
        check_frozen(specification, previous, errors);
    } else {
        check_versioned_change(specification, previous, errors);
    }
}

fn check_elements(
    specification: &Specification,
    previous: &see_model::contract::Anchor,
    errors: &mut Vec<String>,
) {
    for (id, kind) in &previous.elements {
        let current = specification
            .blocks
            .iter()
            .find(|block| field(block, "id") == id);
        if current.is_none()
            || (kind == "lapida" && current.is_some_and(|block| block.kind != "lapida"))
        {
            errors.push(format!("SEE-IDENTITY: missing or reused tombstone {id}"));
        }
    }
}

fn check_frozen(
    specification: &Specification,
    previous: &see_model::contract::Anchor,
    errors: &mut Vec<String>,
) {
    if previous.state != specification.metadata.estado {
        errors.push("SEE-STATE: lifecycle state is frozen".to_owned());
    }
    if previous.version != specification.metadata.version
        && !baseline_promotion(specification, previous)
    {
        errors.push("SEE-VERSION: version is frozen".to_owned());
    }
}

fn baseline_promotion(
    specification: &Specification,
    previous: &see_model::contract::Anchor,
) -> bool {
    let metadata = &specification.metadata;
    previous.state == "estable"
        && metadata.estado == "estable"
        && metadata.version == "1.0.0"
        && metadata.cambio.is_none()
        && semver::Version::parse(&previous.version)
            .ok()
            .is_some_and(|version| version < semver::Version::new(1, 0, 0))
}

fn check_versioned_change(
    specification: &Specification,
    previous: &see_model::contract::Anchor,
    errors: &mut Vec<String>,
) {
    if previous.version == specification.metadata.version {
        return;
    }
    let increased = semver::Version::parse(&specification.metadata.version)
        .ok()
        .zip(semver::Version::parse(&previous.version).ok())
        .is_some_and(|(current, previous)| current > previous);
    if !increased {
        errors.push("SEE-VERSION: version must increase".to_owned());
    }
    if specification.metadata.cambio.is_some() {
        check_change(specification, errors);
    }
    version_step(specification, previous, errors);
}

fn check_change(specification: &Specification, errors: &mut Vec<String>) {
    let Some(change) = &specification.metadata.cambio else {
        errors.push("SEE-CLASSIFICATION: change classification and impact required".to_owned());
        return;
    };
    if change.impacto_usuarios.is_empty()
        || change.impacto_implementaciones.is_empty()
        || change.justificacion.is_empty()
        || change.revisado_por.is_empty()
        || ![
            "editorial",
            "verificacion_anadida",
            "aclaracion",
            "ampliacion",
            "restriccion",
            "cambio_significado",
            "deprecacion",
            "retirada",
        ]
        .contains(&change.clase.as_str())
    {
        errors.push("SEE-CLASSIFICATION: invalid classification".to_owned());
    }
}

pub fn transition(previous: &str, current: &str) -> bool {
    previous == current
        || matches!(
            (previous, current),
            ("borrador", "propuesta" | "rechazada")
                | ("propuesta", "experimental" | "rechazada")
                | ("experimental", "estable" | "rechazada")
                | ("estable", "obsoleta")
                | ("obsoleta", "retirada")
        )
}

fn stability(specification: &Specification) -> Vec<String> {
    let metadata = &specification.metadata;
    let mut errors = Vec::new();
    if metadata.estado != "estable" {
        return errors;
    }
    if metadata.revisado_por.is_empty()
        || metadata
            .revisado_por
            .iter()
            .all(|reviewer| metadata.duenos.contains(reviewer))
    {
        errors.push("SEE-STATE: independent review required".to_owned());
    }
    if specification
        .blocks
        .iter()
        .any(|block| block.kind == "pregunta")
    {
        errors.push("SEE-STATE: stable specification has open question".to_owned());
    }
    if metadata.id.starts_with("LANG.") && metadata.sujetos.len() < 2 {
        errors.push("SEE-STATE: language stability needs two subjects".to_owned());
    }
    errors
}

fn version_step(
    specification: &Specification,
    previous: &see_model::contract::Anchor,
    errors: &mut Vec<String>,
) {
    let metadata = &specification.metadata;
    if ["retirada", "rechazada"].contains(&previous.state.as_str()) {
        errors.push("SEE-IDENTITY: terminal identity is immutable".to_owned());
    }
    let Some(change) = &metadata.cambio else {
        return;
    };
    let (Ok(current), Ok(original)) = (
        semver::Version::parse(&metadata.version),
        semver::Version::parse(&previous.version),
    ) else {
        return;
    };
    let required = match change.clase.as_str() {
        "restriccion" | "cambio_significado" | "retirada" => current.major > original.major,
        "aclaracion" | "ampliacion" | "deprecacion" => {
            current.major > original.major || current.minor > original.minor
        }
        _ => current > original,
    };
    if !required {
        errors.push("SEE-VERSION: bump does not match classification".to_owned());
    }
    if metadata.id.starts_with("LANG.")
        && previous.state == "estable"
        && ["restriccion", "cambio_significado", "retirada"].contains(&change.clase.as_str())
        && metadata.edicion == previous.edition
    {
        errors
            .push("SEE-EDITION: incompatible stable language change needs new edition".to_owned());
    }
}

pub fn active_subjects(corpus: &see_model::Corpus, active: &[String]) -> Vec<String> {
    corpus
        .iter()
        .filter(|specification| {
            specification.metadata.estado == "estable"
                && specification.metadata.id.starts_with("LANG.")
        })
        .filter(|specification| {
            specification
                .metadata
                .sujetos
                .iter()
                .filter(|subject| active.contains(subject))
                .count()
                < 2
        })
        .map(|specification| {
            format!(
                "SEE-STATE: {} needs two active subjects",
                specification.metadata.id
            )
        })
        .collect()
}
