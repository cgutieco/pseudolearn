#![forbid(unsafe_code)]

pub mod bindings;
pub mod identity;
pub mod lifecycle;
pub mod migration;
pub mod references;
pub mod resources;
pub mod schema;
pub mod schema_engine;

use see_model::{Corpus, contract::Lock};

pub fn validate(corpus: &Corpus, lock: &Lock) -> Result<Vec<String>, String> {
    let mut errors = Vec::new();
    if corpus.is_empty() {
        errors.push("SEE-FORMAT: empty corpus".to_owned());
    }
    errors.extend(identity::check(corpus));
    errors.extend(see_graph::validate(corpus));
    errors.extend(see_change::locking::check(corpus, lock)?);
    for specification in corpus {
        errors.extend(schema::check(specification));
        errors.extend(references::check(specification));
        errors.extend(references::capture_review(specification));
        errors.extend(lifecycle::check(specification, lock));
        errors.extend(resources::check(specification));
    }
    errors.sort();
    errors.dedup();
    Ok(errors)
}
