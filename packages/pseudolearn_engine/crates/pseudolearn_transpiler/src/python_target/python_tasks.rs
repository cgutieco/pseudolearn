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
        if failure.is_some() {
            self.block("task_failure", span);
            return;
        }
        self.require("tasks");
        let name = match self.scope.task_scopes.len() {
            0 => "task_scope".to_owned(),
            depth => format!("task_scope_{}", depth.saturating_add(1)),
        };
        lines.line(&format!("{name} = TaskScope()"));
        self.scope.task_scopes.push(name.clone());
        let mut own = CodeLines::default();
        self.body(body, &mut own);
        lines.append(own);
        self.scope.task_scopes.pop();
        lines.line(&format!("await {name}.join()"));
    }
}
