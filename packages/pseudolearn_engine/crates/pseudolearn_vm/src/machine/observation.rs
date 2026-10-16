#![forbid(unsafe_code)]

use crate::Fault;
use crate::evaluate::branch_truth;
use crate::events::{EventPayload, TraceClass, TraceEvent};
use crate::load::model::ObservationKind;
use crate::machine::{Flow, Machine};
use crate::model::LimitKind;

impl Machine<'_> {
    pub(crate) fn observe(&mut self, site: u32) -> Result<Flow, Fault> {
        let site_index = usize::try_from(site).map_err(|_| "invalidBytecode")?;
        let observation = self
            .current
            .observations
            .get(site_index)
            .copied()
            .ok_or("invalidBytecode")?;

        match observation.kind {
            ObservationKind::StatementEnter => self.observe_statement_enter(observation.line),
            ObservationKind::StatementExit => self.observe_statement_exit(observation.line),
            ObservationKind::DecideBool { condition } => {
                self.observe_decide_bool(observation.line, condition)
            }
            ObservationKind::DecideCase { index } => {
                self.observe_decide_case(observation.line, index)
            }
            ObservationKind::DecideDefault => self.observe_decide_default(observation.line),
            ObservationKind::DecideNone => self.observe_decide_none(observation.line),
        }
    }

    fn observe_statement_enter(&mut self, line: u32) -> Result<Flow, Fault> {
        self.statements_executed = self.statements_executed.saturating_add(1);
        if let Some(limit) = self.options.statement_limit
            && self.statements_executed > limit
        {
            let position = self.cursor.program_counter.saturating_sub(1);
            let mut trap = self.trap_context("statementBudgetExhausted", position);
            trap.arguments.insert(
                "limit",
                pseudolearn_diagnostics::DiagnosticArgument::Number(limit.into()),
            );
            self.diagnostics.push(trap);
            return Ok(Flow::LimitReached(LimitKind::Statements));
        }
        if let Some(cancel_statement) = self.options.cancel_at_statement
            && self.statements_executed >= cancel_statement
        {
            return Ok(Flow::Cancelled);
        }
        if self.is_externally_cancelled() {
            return Ok(Flow::Cancelled);
        }
        if self.probed {
            self.change_buffer.clear();
            self.input_requested_emitted = false;
            let depth = self.current_depth();
            self.events.push(TraceEvent {
                class: TraceClass::StatementEntered,
                line,
                depth,
                payload: None,
            });
        }
        Ok(Flow::Continue)
    }

    fn observe_statement_exit(&mut self, line: u32) -> Result<Flow, Fault> {
        if self.probed {
            let depth = self.current_depth();
            self.events.push(TraceEvent {
                class: TraceClass::StatementExited,
                line,
                depth,
                payload: None,
            });
        }
        Ok(Flow::Continue)
    }

    fn observe_decide_bool(&mut self, line: u32, condition: u16) -> Result<Flow, Fault> {
        self.polls_executed = self.polls_executed.saturating_add(1);
        if let Some(cancel_poll) = self.options.cancel_at_poll
            && self.polls_executed >= cancel_poll
        {
            return Ok(Flow::Cancelled);
        }
        if self.is_externally_cancelled() {
            return Ok(Flow::Cancelled);
        }
        if self.probed {
            let word = self.scalar(condition)?;
            let affirmative = branch_truth(word)?;
            let rama = if affirmative {
                "afirmativa".to_string()
            } else {
                "negativa".to_string()
            };
            let depth = self.current_depth();
            self.events.push(TraceEvent {
                class: TraceClass::Decision,
                line,
                depth,
                payload: Some(EventPayload::Decision { rama, indice: None }),
            });
        }
        Ok(Flow::Continue)
    }

    fn observe_decide_case(&mut self, line: u32, index: u16) -> Result<Flow, Fault> {
        if self.probed {
            let word = self.scalar(index)?;
            let case_index = word;
            let depth = self.current_depth();
            self.events.push(TraceEvent {
                class: TraceClass::Decision,
                line,
                depth,
                payload: Some(EventPayload::Decision {
                    rama: "caso".to_string(),
                    indice: Some(case_index),
                }),
            });
        }
        Ok(Flow::Continue)
    }

    fn observe_decide_default(&mut self, line: u32) -> Result<Flow, Fault> {
        if self.probed {
            let depth = self.current_depth();
            self.events.push(TraceEvent {
                class: TraceClass::Decision,
                line,
                depth,
                payload: Some(EventPayload::Decision {
                    rama: "otro".to_string(),
                    indice: None,
                }),
            });
        }
        Ok(Flow::Continue)
    }

    fn observe_decide_none(&mut self, line: u32) -> Result<Flow, Fault> {
        if self.probed {
            let depth = self.current_depth();
            self.events.push(TraceEvent {
                class: TraceClass::Decision,
                line,
                depth,
                payload: Some(EventPayload::Decision {
                    rama: "ninguna".to_string(),
                    indice: None,
                }),
            });
        }
        Ok(Flow::Continue)
    }

    fn is_externally_cancelled(&self) -> bool {
        self.options
            .cancelled
            .as_ref()
            .map(|flag| flag.load(std::sync::atomic::Ordering::Relaxed))
            .unwrap_or(false)
    }
}
