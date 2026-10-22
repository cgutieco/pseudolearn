use see_model::Metadata;

pub fn metadata(id: &str, domain: &str) -> Metadata {
    let (domain_name, subjects) = domain_contract(domain);
    Metadata {
        formato: "see/1".to_owned(),
        id: id.to_owned(),
        titulo: "Contrato por redactar".to_owned(),
        dominio: domain_name.to_owned(),
        estado: "estable".to_owned(),
        version: "1.0.0".to_owned(),
        duenos: vec!["responsable-especificaciones".to_owned()],
        sujetos: subjects
            .iter()
            .map(|subject| (*subject).to_owned())
            .collect(),
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

fn domain_contract(domain: &str) -> (&'static str, &'static [&'static str]) {
    match domain {
        "lang" => ("lenguaje", &["engine", "aot"]),
        "diag" => ("lenguaje", &["engine"]),
        "see" => ("proceso", &["see"]),
        "lib" => ("biblioteca", &["engine"]),
        "ir" => ("ri", &["engine"]),
        "eng" => ("motor", &["engine"]),
        "mem" => ("memoria", &["engine"]),
        "rt" => ("motor", &["aot"]),
        "api" => ("motor", &["engine"]),
        "tool" => ("herramienta", &["cli"]),
        "app" => ("app", &["app"]),
        "perf" => ("rendimiento", &["engine"]),
        _ => ("proceso", &["see"]),
    }
}
