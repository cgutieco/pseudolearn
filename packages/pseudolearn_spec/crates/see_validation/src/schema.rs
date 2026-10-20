use see_model::{Block, Specification, field, strings};

pub fn check(specification: &Specification) -> Vec<String> {
    let mut errors = serialized(specification);
    let metadata = &specification.metadata;
    if metadata.formato != "see/1"
        || metadata.titulo.is_empty()
        || metadata.resumen.is_empty()
        || metadata.duenos.is_empty()
        || metadata.sujetos.is_empty()
    {
        errors.push(format!("SEE-SCHEMA: incomplete metadata {}", metadata.id));
    }
    if semver::Version::parse(&metadata.version).is_err() {
        errors.push("SEE-VERSION: invalid semantic version".to_owned());
    }
    if ![
        "lenguaje",
        "ri",
        "motor",
        "memoria",
        "biblioteca",
        "herramienta",
        "app",
        "rendimiento",
        "proceso",
    ]
    .contains(&metadata.dominio.as_str())
    {
        errors.push("SEE-SCHEMA: invalid domain".to_owned());
    }
    for block in &specification.blocks {
        check_block(block, &mut errors);
    }
    errors
}

fn check_block(block: &Block, errors: &mut Vec<String>) {
    if block
        .fields
        .get("semilla")
        .is_some_and(|value| value.as_i64().is_none())
    {
        errors.push("SEE-SCHEMA: seed must be a signed 64-bit integer".to_owned());
    }
    let (required, optional) = fields(&block.kind);
    for name in required.split_whitespace() {
        if !block.fields.contains_key(name) {
            errors.push(format!("SEE-SCHEMA: missing {name} in {}", block.kind));
        }
    }
    for name in block.fields.keys() {
        if !required
            .split_whitespace()
            .chain(optional.split_whitespace())
            .any(|allowed| allowed == name)
        {
            errors.push(format!("SEE-SCHEMA: unknown {name} in {}", block.kind));
        }
    }
    if block.kind == "regla"
        && !["DEBE", "NO DEBE", "DEBERÍA", "NO DEBERÍA", "PUEDE"].contains(&field(block, "fuerza"))
    {
        errors.push("SEE-FORCE: invalid normative force".to_owned());
    }
    if block.kind == "caso" {
        check_case(block, errors);
        check_app_case(block, errors);
    }
}

pub fn fields(kind: &str) -> (&'static str, &'static str) {
    match kind {
        "regla" => (
            "id fuerza clase texto verificacion",
            "justificacion referencias",
        ),
        "caso" => (
            "id regla perfiles rigor espera origen",
            "programa programas programa_ri cli servicio aplicacion paginacion limites cancelacion cancelacion_prueba esperas entradas etiquetas revisado_por exclusiones perfil_base operacion produce evita semilla sujetos",
        ),
        "definicion" => ("id termino texto", "valor"),
        "error" => ("id situacion clase codigo severidad", ""),
        "propiedad" => ("id regla generador propiedad oraculo", "justificacion"),
        "lapida" => ("id justificacion", "reemplazada_por"),
        "pregunta" => ("id texto", ""),
        "medicion" => (
            "id metrica unidad suite comparador umbral provisional plataformas protocolo",
            "sujetos",
        ),
        "instruccion" => (
            "id nombre firma clases_de_valor semantica trampas efectos observacion",
            "",
        ),
        "cobertura" => ("id regla", "instrucciones sin_ri"),
        "invariante" | "precondicion" | "resultado" => ("id texto verificacion", "justificacion"),
        _ => ("invalid", ""),
    }
}

fn check_case(block: &Block, errors: &mut Vec<String>) {
    if !["escrito", "derivado", "capturado"].contains(&field(block, "origen")) {
        errors.push("SEE-ORIGIN: invalid oracle origin".to_owned());
    }
    if field(block, "origen") == "capturado" && field(block, "revisado_por").is_empty() {
        errors.push("SEE-CAPTURE: captured value needs reviewer".to_owned());
    }
    if !block
        .fields
        .get("espera")
        .is_some_and(|value| value.is_object())
    {
        errors.push("SEE-SCHEMA: expected observation must be an object".to_owned());
    }
    check_program(block, errors);
    if block
        .fields
        .get("espera")
        .and_then(|expected| expected.as_object())
        .is_some_and(|expected| expected.is_empty())
    {
        errors.push("SEE-SCHEMA: case needs an observable expectation".to_owned());
    }
    let profiles = strings(block.fields.get("perfiles"));
    if profiles.is_empty()
        || profiles
            .iter()
            .any(|profile| !["es", "en"].contains(profile))
    {
        errors.push("SEE-PROFILE: invalid profiles".to_owned());
    }
    let strictness = strings(block.fields.get("rigor"));
    if strictness.is_empty()
        || strictness
            .iter()
            .any(|rigor| !["estricto", "flexible"].contains(rigor))
    {
        errors.push("SEE-SCHEMA: invalid strictness".to_owned());
    }
}

fn serialized(specification: &Specification) -> Vec<String> {
    let outcome = serde_json::from_str::<serde_json::Value>(include_str!(
        "../../../schemas/see-1.schema.json"
    ))
    .map_err(|error| error.to_string())
    .and_then(|schema| {
        serde_json::to_value(specification)
            .map_err(|error| error.to_string())
            .and_then(|value| crate::schema_engine::check(&value, &schema, &schema, 0))
    });
    outcome.err().into_iter().collect()
}

fn check_program(block: &Block, errors: &mut Vec<String>) {
    let operation_source = match field(block, "operacion") {
        "ir" => Some("programa_ri"),
        "cli" => Some("cli"),
        "service" => Some("servicio"),
        "app" => return,
        _ => None,
    };
    if let Some(source) = operation_source {
        if !block.fields.contains_key(source) {
            errors.push(format!("SEE-SCHEMA: case {source} required"));
        }
        return;
    }
    if !block
        .fields
        .get("programa")
        .is_some_and(|value| value.is_string())
        && !block
            .fields
            .get("programas")
            .is_some_and(|value| value.is_object())
    {
        errors.push("SEE-SCHEMA: case program required".to_owned());
    }
}

fn check_app_case(block: &Block, errors: &mut Vec<String>) {
    let application = block.fields.get("aplicacion");
    if field(block, "operacion") == "app" && !application.is_some_and(serde_json::Value::is_object)
    {
        errors.push("SEE-APP-CASE: application input required".to_owned());
    }
    if field(block, "operacion") != "app" && application.is_some() {
        errors.push("SEE-APP-CASE: application input requires app operation".to_owned());
    }
}
