use crate::model::ApiDiagnostic;
use pseudolearn_diagnostics::{Diagnostic, DiagnosticArgument, DiagnosticCode, TypeName};
use std::collections::BTreeMap;

pub(crate) fn resolve(diagnostic: &Diagnostic, profile: &str) -> Diagnostic {
    let mut resolved = diagnostic.clone();
    for argument in resolved.arguments.values_mut() {
        match argument {
            DiagnosticArgument::Token(identity) => {
                *identity = pseudolearn_lexicon::keywords::keyword_lexeme(identity, profile)
                    .unwrap_or(identity)
                    .to_owned();
            }
            DiagnosticArgument::Type(kind) => {
                let name = match &kind.name {
                    TypeName::Token(identity) => {
                        pseudolearn_lexicon::keywords::keyword_lexeme(identity, profile)
                            .unwrap_or(identity)
                            .to_owned()
                    }
                    TypeName::Named(name) => name.clone(),
                };
                kind.name = TypeName::Named(name);
            }
            _ => (),
        }
    }
    resolved
}

pub(crate) fn decode(
    diagnostic: &ApiDiagnostic,
    code: DiagnosticCode,
) -> Option<BTreeMap<String, DiagnosticArgument>> {
    diagnostic
        .arguments
        .iter()
        .map(|(name, value)| {
            Some((
                name.clone(),
                DiagnosticArgument::from_wire(code.argument_kind(name)?, value)?,
            ))
        })
        .collect()
}

pub(crate) fn wire(diagnostic: &Diagnostic) -> BTreeMap<String, serde_json::Value> {
    diagnostic
        .arguments
        .iter()
        .map(|(name, value)| (name.clone(), value.wire()))
        .collect()
}
