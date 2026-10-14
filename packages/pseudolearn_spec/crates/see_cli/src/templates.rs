use see_model::Metadata;

pub fn metadata(id: &str, domain: &str) -> Metadata {
    Metadata {
        formato: "see/1".to_owned(),
        id: id.to_owned(),
        titulo: "Contrato por redactar".to_owned(),
        dominio: domain_contract(domain).0.to_owned(),
        estado: "borrador".to_owned(),
        version: "0.1.0".to_owned(),
        duenos: vec!["responsable-especificaciones".to_owned()],
        sujetos: vec![domain_contract(domain).1.to_owned()],
        resumen: "Contrato por redactar".to_owned(),
        titulo_en: None,
        edicion: if domain == "lang" {
            std::collections::BTreeMap::from([("introducida_en".to_owned(), "2026".to_owned())])
        } else {
            Default::default()
        },
        depende_de: vec![],
        reemplaza: None,
        reemplazada_por: None,
        cambio: None,
        revisado_por: vec![],
    }
}

fn domain_contract(domain: &str) -> (&'static str, &'static str) {
    let domains = [
        ("lang", "lenguaje", "reference"),
        ("diag", "lenguaje", "reference"),
        ("see", "proceso", "see"),
        ("lib", "biblioteca", "reference"),
        ("ir", "ri", "engine"),
        ("eng", "motor", "engine"),
        ("mem", "memoria", "engine"),
        ("rt", "motor", "aot"),
        ("api", "motor", "engine"),
        ("tool", "herramienta", "cli"),
        ("app", "app", "app"),
        ("perf", "rendimiento", "engine"),
    ];
    domains
        .iter()
        .find(|(prefix, _, _)| *prefix == domain)
        .map_or(("proceso", "see"), |(_, contract, subject)| {
            (*contract, *subject)
        })
}
