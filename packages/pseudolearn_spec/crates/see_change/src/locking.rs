use see_model::{
    Corpus,
    contract::{Anchor, Lock},
};

pub fn generate(corpus: &Corpus, previous: &Lock) -> Result<Lock, String> {
    let mut result = previous.clone();
    result.formato = "see-lock/1".to_owned();
    result
        .specifications
        .retain(|_, anchor| ["retirada", "rechazada"].contains(&anchor.state.as_str()));
    for specification in corpus {
        let metadata = &specification.metadata;
        let anchor = Anchor {
            version: metadata.version.clone(),
            hash: crate::hash(specification)?,
            state: metadata.estado.clone(),
            elements: crate::elements(specification),
            edition: metadata.edicion.clone(),
        };
        result
            .specifications
            .insert(metadata.id.clone(), anchor.clone());
        let key = format!("{}@{}", metadata.id, metadata.version);
        if let Some(recorded) = result.history.get(&key)
            && recorded.hash != anchor.hash
        {
            return Err(format!("SEE-HASH: immutable version {key}"));
        }
        result.history.insert(key, anchor);
    }
    Ok(result)
}

pub fn check(corpus: &Corpus, lock: &Lock) -> Result<Vec<String>, String> {
    let mut errors = Vec::new();
    for specification in corpus {
        let key = format!(
            "{}@{}",
            specification.metadata.id, specification.metadata.version
        );
        if let Some(recorded) = lock.history.get(&key)
            && recorded.hash != crate::hash(specification)?
        {
            errors.push(format!("SEE-HASH: content changed without version: {key}"));
        }
    }
    for (id, previous) in &lock.specifications {
        if !corpus
            .iter()
            .any(|specification| &specification.metadata.id == id)
            && previous.state != "retirada"
            && previous.state != "rechazada"
        {
            errors.push(format!(
                "SEE-IDENTITY: removed specification without tombstone {id}"
            ));
        }
    }
    Ok(errors)
}
