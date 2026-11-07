use super::RustEmitter;
use crate::code_lines::CodeLines;
use pseudolearn_semantic::channel_model::{ChannelAction, ChannelExpression, HirSelect};
use pseudolearn_semantic::{ExpressionId, FunctionId, LocalId, StatementId};
use pseudolearn_source::Span;

impl RustEmitter<'_, '_> {
    pub(crate) fn task_scope(
        &mut self,
        (failure, body): (Option<LocalId>, &[StatementId]),
        span: Span,
        lines: &mut CodeLines,
    ) {
        self.require("tasks");
        let name = match self.scope.task_scopes.len() {
            0 => "task_scope".to_owned(),
            depth => format!("task_scope_{}", depth.saturating_add(1)),
        };
        let record = failure.and_then(|local| self.view.failure_record(local));
        let error_type =
            match record.and_then(|found| self.view.module.task_failures.get(&found).copied()) {
                Some(error) => self.type_text(error, span),
                None => "()".to_owned(),
            };
        lines.line(&format!("let {name} = TaskScope::<{error_type}>::new();"));
        self.scope.task_scopes.push(name.clone());
        if record.is_some() {
            lines.open(&format!("{name}.run_body(async {{"));
            self.statements(body, lines);
            lines.close("})");
            lines.line(".await;");
        } else {
            self.statements(body, lines);
        }
        self.scope.task_scopes.pop();
        lines.line(&format!("{name}.join().await;"));
        if let (Some(local), Some(found)) = (failure, record) {
            self.failure_report(local, (found, &name), lines);
        }
    }

    pub(crate) fn failure_report(
        &mut self,
        local: LocalId,
        (record, scope): (pseudolearn_semantic::RecordId, &str),
        lines: &mut CodeLines,
    ) {
        self.scope.declared.insert(local);
        let fields = self
            .view
            .record(record)
            .map(|entry| {
                entry
                    .fields
                    .iter()
                    .map(|field| crate::identifier_spelling::rust_value_name(&field.name))
                    .collect::<Vec<_>>()
            })
            .unwrap_or_default();
        let [first, associated, cancelled] = fields.as_slice() else {
            self.block("task_failure", Span::default());
            return;
        };
        let type_text = self
            .view
            .local(local)
            .map(|entry| (entry.type_id, entry.span));
        let Some((type_id, span)) = type_text else {
            return;
        };
        let type_text = self.type_text(type_id, span);
        let struct_name = self.record_type(record, span);
        let name = self.local_name(local);
        lines.line(&format!(
            "let {name}: {type_text} = {scope}.report().map(|(first, associated, cancelled)| {struct_name} {{ {first}: first, {associated}: Rc::new(RefCell::new(associated)), {cancelled}: cancelled }});"
        ));
    }

    pub(crate) fn spawn(
        &mut self,
        function: FunctionId,
        arguments: &[ExpressionId],
        span: Span,
    ) -> String {
        let Some(scope) = self.scope.task_scopes.last().cloned() else {
            return self.block("spawn_outside_scope", span);
        };
        let name = self.function_name(function);
        let arguments = self.arguments(Some(function), arguments);
        let suspendible = self
            .view
            .function(function)
            .is_some_and(|entry| entry.suspendible);
        if suspendible && self.view.returns_result(function) {
            format!("{scope}.spawn_fallible({name}({arguments}))")
        } else if suspendible {
            format!("{scope}.spawn({name}({arguments}))")
        } else {
            format!("{scope}.spawn(async move {{ {name}({arguments}) }})")
        }
    }

    pub(crate) fn channel_operation(&mut self, channel: &ChannelExpression, span: Span) -> String {
        self.require("channel");
        let receiver = channel.receiver.map(|receiver| self.operand(receiver, 10));
        let argument = channel
            .arguments
            .first()
            .map(|argument| self.value(*argument));
        match (&channel.action, receiver, argument) {
            (ChannelAction::New, _, Some(capacity)) => format!("Channel::new({capacity})"),
            (ChannelAction::Send, Some(receiver), Some(value)) => {
                format!("{receiver}.send({value}).await")
            }
            (ChannelAction::Receive, Some(receiver), _) => format!("{receiver}.receive().await"),
            (ChannelAction::Close, Some(receiver), _) => format!("{receiver}.close()"),
            (ChannelAction::Selected, _, _) => "selected_value.clone()".to_owned(),
            _ => self.block("channel", span),
        }
    }

    pub(crate) fn select(&mut self, selection: &HirSelect, span: Span, lines: &mut CodeLines) {
        self.require("select");
        let channels = selection
            .channels
            .iter()
            .map(|channel| format!("{}.clone()", self.operand(*channel, 10)))
            .collect::<Vec<_>>()
            .join(", ");
        lines.line(&format!(
            "let (selected, selected_value) = select_receive(&[{channels}]).await;"
        ));
        lines.open("match selected {");
        for case in &selection.cases {
            let labels = case
                .labels
                .iter()
                .map(|label| self.expression(*label))
                .collect::<Vec<_>>()
                .join(" | ");
            lines.open(&format!("{labels} => {{"));
            self.statements(&case.body, lines);
            lines.close("}");
        }
        lines.line("_ => {}");
        lines.close("}");
        let _ = span;
    }
}
