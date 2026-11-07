mod rust_builtins;
mod rust_calls;
mod rust_classes;
mod rust_cleanups;
mod rust_closures;
mod rust_collections;
mod rust_control;
mod rust_declarations;
mod rust_expressions;
mod rust_functions;
mod rust_hierarchy;
mod rust_loops;
mod rust_mutation;
mod rust_operators;
mod rust_places;
mod rust_statements;
mod rust_support;
mod rust_support_catalog;
mod rust_support_tasks;
mod rust_support_text;
mod rust_tasks;
mod rust_trait_impls;
mod rust_types;
mod rust_variants;

use crate::code_lines::CodeLines;
use crate::module_view::ModuleView;
use crate::outcome::{Blocker, TranspileOutcome};
use crate::support_requests::SupportRequests;
use crate::target::TranspileRequest;
use pseudolearn_semantic::{ClassId, LocalId};
use pseudolearn_source::Span;
use std::collections::BTreeSet;

#[derive(Default)]
pub(crate) struct CleanupFrame {
    pub(crate) loop_boundary: bool,
    pub(crate) bodies: Vec<Vec<pseudolearn_semantic::StatementId>>,
}

#[derive(Default)]
pub(crate) struct FunctionScope {
    pub(crate) cleanups: Vec<CleanupFrame>,
    pub(crate) declared: BTreeSet<LocalId>,
    pub(crate) owner: Option<ClassId>,
    pub(crate) generic_receiver: bool,
    pub(crate) task_scopes: Vec<String>,
}

pub(crate) struct RustEmitter<'view, 'module> {
    pub(crate) view: &'view ModuleView<'module>,
    pub(crate) request: &'view TranspileRequest,
    pub(crate) support: SupportRequests,
    pub(crate) blockers: Vec<Blocker>,
    pub(crate) scope: FunctionScope,
    pub(crate) uses: BTreeSet<&'static str>,
    pub(crate) preamble: CodeLines,
    pub(crate) closures: usize,
    pub(crate) mutation: rust_mutation::Mutation,
}

impl<'view, 'module> RustEmitter<'view, 'module> {
    pub(crate) fn block(&mut self, construct: &str, span: Span) -> String {
        self.blockers.push(Blocker {
            construct: construct.to_owned(),
            span,
        });
        "()".to_owned()
    }

    pub(crate) fn require(&mut self, name: &'static str) -> &'static str {
        self.support.request(name);
        name
    }
}

pub(crate) fn emit_program(view: &ModuleView<'_>, request: &TranspileRequest) -> TranspileOutcome {
    let mut emitter = RustEmitter {
        view,
        request,
        support: SupportRequests::default(),
        blockers: Vec::new(),
        scope: FunctionScope::default(),
        uses: BTreeSet::new(),
        preamble: CodeLines::default(),
        closures: 0,
        mutation: rust_mutation::Mutation::of(view),
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
    emitter.write_uses(&mut program);
    program.append(body);
    emitter.write_support(&mut program);
    TranspileOutcome::Code(program.finish())
}
