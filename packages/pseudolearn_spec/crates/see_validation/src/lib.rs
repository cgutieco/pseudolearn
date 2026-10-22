#![forbid(unsafe_code)]

pub mod bindings;
pub mod cli;
pub mod coverage;
pub mod expectations;
pub mod identity;
pub mod lifecycle;
pub mod measurement;
pub mod messages;
pub mod migration;
pub mod openers;
pub mod property_registry;
pub mod references;
pub mod resources;
pub mod schema;
pub mod schema_engine;
pub mod trace;

use see_model::{Corpus, contract::Lock};

pub fn validate(corpus: &Corpus, lock: &Lock) -> Result<Vec<String>, String> {
    let mut errors = Vec::new();
    if corpus.is_empty() {
        errors.push("SEE-FORMAT: empty corpus".to_owned());
    }
    errors.extend(identity::check(corpus));
    errors.extend(see_graph::validate(corpus));
    errors.extend(see_change::locking::check(corpus, lock)?);
    errors.extend(trace::check(corpus));
    errors.extend(cli::check(corpus));
    errors.extend(coverage::check(corpus));
    errors.extend(measurement::check(corpus));
    errors.extend(resources::check_references(corpus));
    for specification in corpus {
        errors.extend(schema::check(specification));
        errors.extend(references::check(specification));
        errors.extend(references::capture_review(specification));
        errors.extend(lifecycle::check(specification, lock));
        errors.extend(resources::check(specification));
        errors.extend(expectations::check(specification));
    }
    errors.sort();
    errors.dedup();
    Ok(errors)
}
