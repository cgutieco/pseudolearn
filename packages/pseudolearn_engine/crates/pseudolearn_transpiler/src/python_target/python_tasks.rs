use super::PythonEmitter;
use crate::code_lines::CodeLines;
use pseudolearn_semantic::{LocalId, StatementId};
use pseudolearn_source::Span;

impl PythonEmitter<'_, '_> {
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
        lines.line(&format!("{name} = TaskScope()"));
        self.scope.task_scopes.push(name.clone());
        let mut own = CodeLines::default();
        self.body(body, &mut own);
        self.scope.task_scopes.pop();
        if failure.is_some() {
            lines.open("try:");
            lines.append(own);
            lines.dedent();
            lines.open("except asyncio.CancelledError:");
            lines.line(&format!("{name}.absorb()"));
            lines.dedent();
            lines.line(&format!("{name}.close_body()"));
        } else {
            lines.append(own);
        }
        lines.line(&format!("await {name}.join()"));
        let record = failure.and_then(|local| self.view.failure_record(local));
        if let (Some(local), Some(found)) = (failure, record) {
            self.require("variants");
            let target = self.local_name(local);
            let record_name = self.record_name(found);
            lines.line(&format!("{target} = {name}.report({record_name})"));
        }
        let _ = span;
    }
}
