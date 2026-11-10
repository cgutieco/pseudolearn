mod python_builtins;
mod python_calls;
mod python_channels;
mod python_classes;
mod python_control;
mod python_declarations;
mod python_expressions;
mod python_functions;
mod python_places;
mod python_statements;
mod python_support;
mod python_support_catalog;
mod python_support_text;
mod python_tasks;
mod python_variants;

use crate::code_lines::CodeLines;
use crate::module_view::ModuleView;
use crate::outcome::{Blocker, TranspileOutcome};
use crate::support_requests::SupportRequests;
use crate::target::TranspileRequest;
use pseudolearn_semantic::LocalId;
use pseudolearn_source::Span;
use std::collections::BTreeSet;

#[derive(Default)]
pub(crate) struct PythonScope {
    pub(crate) task_scopes: Vec<String>,
    pub(crate) reference_parameters: Vec<LocalId>,
    pub(crate) declared: BTreeSet<LocalId>,
    pub(crate) aliases: std::collections::BTreeMap<LocalId, LocalId>,
}

pub(crate) struct PythonEmitter<'view, 'module> {
    pub(crate) view: &'view ModuleView<'module>,
    pub(crate) request: &'view TranspileRequest,
    pub(crate) support: SupportRequests,
    pub(crate) blockers: Vec<Blocker>,
    pub(crate) scope: PythonScope,
    pub(crate) preamble: CodeLines,
    pub(crate) temporaries: usize,
    pub(crate) names: crate::member_spellings::MemberSpellings,
}

impl PythonEmitter<'_, '_> {
    pub(crate) fn block(&mut self, construct: &str, span: Span) -> String {
        self.blockers.push(Blocker {
            construct: construct.to_owned(),
            span,
        });
        "None".to_owned()
    }

    pub(crate) fn require(&mut self, name: &'static str) -> &'static str {
        self.support.request(name);
        name
    }

    pub(crate) fn temporary(&mut self, stem: &str) -> String {
        self.temporaries = self.temporaries.saturating_add(1);
        format!("{stem}{}", self.temporaries)
    }
}

pub(crate) fn emit_program(view: &ModuleView<'_>, request: &TranspileRequest) -> TranspileOutcome {
    let mut emitter = PythonEmitter {
        view,
        request,
        support: SupportRequests::default(),
        blockers: Vec::new(),
        scope: PythonScope::default(),
        preamble: CodeLines::default(),
        temporaries: 0,
        names: crate::member_spellings::MemberSpellings::new(
            view,
            &crate::member_spellings::SpellingRules {
                value: crate::identifier_spelling::python_value_name,
                type_name: crate::identifier_spelling::python_type_name,
            },
        ),
    };
    let mut body = CodeLines::default();
    emitter.declarations(&mut body);
    emitter.classes(&mut body);
    emitter.functions(&mut body);
    if !emitter.blockers.is_empty() {
        let mut blockers = emitter.blockers;
        blockers.sort_by_key(|blocker| (blocker.span.start, blocker.construct.clone()));
        blockers.dedup();
        return TranspileOutcome::Unavailable(blockers);
    }
    let mut program = CodeLines::default();
    emitter.write_imports(&mut program);
    emitter.write_support(&mut program);
    program.append(body);
    TranspileOutcome::Code(program.finish())
}
