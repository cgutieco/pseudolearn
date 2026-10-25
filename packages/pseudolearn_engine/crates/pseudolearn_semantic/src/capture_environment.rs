use crate::expression_model::{HirExpression, HirPlace};
use crate::hir::{HirClass, HirField};
use crate::identities::{ClassId, FieldId, FunctionId, StatementId};
use crate::session::AnalysisSession;
use crate::statement_model::HirStatement;
use crate::types::ValueClass;
use pseudolearn_abi::{ClosureLayout, RecordBank, RecordLayout};

pub(crate) fn finish(
    session: &mut AnalysisSession<'_>,
    function: FunctionId,
    body: Vec<StatementId>,
) {
    let (leaves, offsets, mut prologue) = prologue(session, function);
    let layout = layout(session, &leaves);
    if layout.is_none() {
        report_limit(session, function);
    }
    let class = layout
        .as_ref()
        .filter(|_| !leaves.is_empty())
        .map(|layout| environment_class(session, function, (&leaves, layout)));
    if let Some(closure) = session.module.closures.get_mut(&function) {
        closure.offsets = offsets;
        closure.layout = layout;
        closure.class = class;
    }
    prologue.extend(body);
    if let Some(model) = usize::try_from(function.0)
        .ok()
        .and_then(|index| session.module.functions.get_mut(index))
    {
        model.body = prologue;
    }
}

fn environment_class(
    session: &mut AnalysisSession<'_>,
    function: FunctionId,
    (leaves, layout): (&[crate::identities::TypeId], &ClosureLayout),
) -> ClassId {
    let class = ClassId(u32::try_from(session.module.classes.len()).unwrap_or(u32::MAX));
    let span = usize::try_from(function.0)
        .ok()
        .and_then(|index| session.module.functions.get(index))
        .map(|function| function.span)
        .unwrap_or_default();
    let fields = fields(class, (leaves, layout), span);
    session.tag_class();
    session.module.classes.push(HirClass {
        name: format!("$environment{}", function.0),
        superclass: None,
        fields,
        methods: Vec::new(),
        virtual_slots: Vec::new(),
        constructor: None,
        span,
        syntax: usize::MAX,
    });
    class
}

fn prologue(
    session: &mut AnalysisSession<'_>,
    function: FunctionId,
) -> (Vec<crate::identities::TypeId>, Vec<u32>, Vec<StatementId>) {
    let captures = session
        .module
        .closures
        .get(&function)
        .map(|closure| closure.captures.clone())
        .unwrap_or_default();
    let mut leaves = Vec::new();
    let mut offsets = Vec::new();
    let mut statements = Vec::new();
    for (index, (_, proxy)) in captures.iter().enumerate() {
        let Some(local) = crate::closure_locals::get(session, *proxy) else {
            continue;
        };
        offsets.push(u32::try_from(leaves.len()).unwrap_or(u32::MAX));
        leaves.extend(crate::variant_types::leaves(session, local.type_id));
        let value = session.emit(
            HirExpression::Captured {
                function,
                capture: u32::try_from(index).unwrap_or(u32::MAX),
            },
            local.type_id,
            local.span,
        );
        statements.push(session.statement(
            HirStatement::Assign {
                destination: HirPlace::Local(*proxy),
                value,
            },
            local.span,
        ));
    }
    (leaves, offsets, statements)
}

fn fields(
    class: ClassId,
    (leaves, layout): (&[crate::identities::TypeId], &ClosureLayout),
    span: pseudolearn_source::Span,
) -> Vec<HirField> {
    let mut fields: Vec<_> = leaves
        .iter()
        .enumerate()
        .filter_map(|(index, kind)| Some((layout.field(index)?, *kind)))
        .collect();
    fields.sort_by_key(|(offset, _)| *offset);
    let fields = fields
        .into_iter()
        .map(|(offset, kind)| HirField {
            id: FieldId(offset),
            name: format!("capture{offset}"),
            type_id: kind,
            owner: class,
            private: false,
            span,
        })
        .collect();
    fields
}

fn report_limit(session: &mut AnalysisSession<'_>, function: FunctionId) {
    if let Some(model) = crate::hierarchy::function(session, function) {
        session
            .diagnostics
            .push(pseudolearn_diagnostics::Diagnostic::new(
                pseudolearn_diagnostics::DiagnosticCode::ClosureEnvironmentTooLarge,
                model.span,
            ));
    }
}

fn layout(
    session: &AnalysisSession<'_>,
    leaves: &[crate::identities::TypeId],
) -> Option<ClosureLayout> {
    let banks: Vec<_> = leaves
        .iter()
        .map(|kind| {
            if session.module.types.value_class(*kind) == ValueClass::Reference {
                RecordBank::Reference
            } else {
                RecordBank::Scalar
            }
        })
        .collect();
    RecordLayout::from_banks(&banks)
        .ok()
        .and_then(|layout| ClosureLayout::from_captures(&[layout]).ok())
}
