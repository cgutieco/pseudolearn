use see_model::{Change, Metadata};

#[test]
fn absent_change_is_omitted_and_defaults_when_reading() -> Result<(), String> {
    let metadata = sample_metadata();
    let value = serde_json::to_value(&metadata).map_err(|error| error.to_string())?;
    assert!(value.get("cambio").is_none());
    let restored: Metadata = serde_json::from_value(value).map_err(|error| error.to_string())?;
    assert!(restored.cambio.is_none());
    Ok(())
}

#[test]
fn declared_change_is_preserved() -> Result<(), String> {
    let mut metadata = sample_metadata();
    metadata.cambio = Some(Change {
        clase: "editorial".to_owned(),
        impacto_usuarios: "ninguno".to_owned(),
        impacto_implementaciones: "ninguno".to_owned(),
        justificacion: "Edición oficial".to_owned(),
        revisado_por: "independent-reviewer".to_owned(),
    });
    let value = serde_json::to_value(&metadata).map_err(|error| error.to_string())?;
    assert!(value.get("cambio").is_some());
    let restored: Metadata = serde_json::from_value(value).map_err(|error| error.to_string())?;
    assert_eq!(restored.cambio, metadata.cambio);
    Ok(())
}

fn sample_metadata() -> Metadata {
    Metadata {
        formato: "see/1".to_owned(),
        id: "SEE.TEST.METADATA".to_owned(),
        titulo: "Contrato".to_owned(),
        dominio: "proceso".to_owned(),
        estado: "estable".to_owned(),
        version: "1.0.0".to_owned(),
        duenos: vec!["specification-owner".to_owned()],
        sujetos: vec!["see".to_owned()],
        resumen: "Contrato estable".to_owned(),
        titulo_en: None,
        edicion: Default::default(),
        depende_de: Vec::new(),
        reemplaza: None,
        reemplazada_por: None,
        cambio: None,
        revisado_por: vec!["independent-reviewer".to_owned()],
    }
}
