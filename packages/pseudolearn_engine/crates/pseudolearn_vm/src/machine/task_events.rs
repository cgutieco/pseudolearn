use super::Machine;
use crate::events::{EventField, EventPayload, TraceClass, TraceEvent};
use pseudolearn_runtime::TaskId;

type Fields = Vec<(&'static str, EventField)>;

fn number(value: u64) -> EventField {
    EventField::Number(value)
}

fn text(value: &str) -> EventField {
    EventField::Text(value.to_owned())
}

impl Machine<'_> {
    fn emit_task_event(&mut self, class: TraceClass, fields: Fields) {
        let upcoming = matches!(class, TraceClass::TaskSuspended | TraceClass::TaskResumed);
        self.push_task_event(class, fields, upcoming);
    }

    fn push_task_event(&mut self, class: TraceClass, fields: Fields, upcoming: bool) {
        if !self.probed {
            return;
        }
        let span = if upcoming {
            self.current
                .span(self.cursor.program_counter, self.probed)
                .or(self.current.declaration_span)
        } else {
            self.current_span()
        };
        let line = span.map_or(1, |found| found.start_line);
        let depth = self.current_depth();
        self.events.push(TraceEvent {
            class,
            line,
            depth,
            span,
            payload: Some(EventPayload::Fields(fields)),
        });
    }

    pub(super) fn event_task_spawned(&mut self, task: TaskId, scope: u64) {
        let parent = self.tasks.current.0;
        self.emit_task_event(
            TraceClass::TaskSpawned,
            vec![
                ("task", number(task.0)),
                ("parent", number(parent)),
                ("scope", number(scope)),
            ],
        );
    }

    pub(super) fn event_task_suspended(&mut self, cause: &str, target: u64) {
        let task = self.tasks.current.0;
        self.emit_task_event(
            TraceClass::TaskSuspended,
            vec![
                ("task", number(task)),
                ("cause", text(cause)),
                ("target", number(target)),
            ],
        );
    }

    pub(super) fn event_task_resumed(&mut self) {
        let task = self.tasks.current.0;
        self.emit_task_event(TraceClass::TaskResumed, vec![("task", number(task))]);
    }

    pub(super) fn event_task_completed(&mut self, task: TaskId, outcome: &str) {
        self.emit_task_event(
            TraceClass::TaskCompleted,
            vec![("task", number(task.0)), ("outcome", text(outcome))],
        );
    }

    pub(super) fn event_cancel_requested(&mut self, task: TaskId, reason: &str, origin: u64) {
        self.emit_task_event(
            TraceClass::TaskCancelRequested,
            vec![
                ("task", number(task.0)),
                ("reason", text(reason)),
                ("origin", number(origin)),
            ],
        );
    }

    pub(super) fn event_scope_joined(&mut self, failed: bool) {
        let task = self.tasks.current.0;
        let outcome = if failed { "failure" } else { "success" };
        self.emit_task_event(
            TraceClass::ScopeJoined,
            vec![("task", number(task)), ("outcome", text(outcome))],
        );
    }

    pub(super) fn event_channel(&mut self, class: TraceClass, channel: u64, extra: Fields) {
        let mut fields = vec![("channel", number(channel))];
        fields.extend(extra);
        self.emit_task_event(class, fields);
    }

    pub(super) fn event_effect_delivered(&mut self, effect_seq: u64) {
        self.tasks.delivered_effects = self.tasks.delivered_effects.saturating_add(1);
        let delivery = self.tasks.delivered_effects;
        let task = self.tasks.current.0;
        self.emit_task_event(
            TraceClass::EffectDelivered,
            vec![
                ("effect_seq", number(effect_seq)),
                ("delivery_seq", number(delivery)),
                ("task", number(task)),
            ],
        );
    }

    pub(super) fn sync_ready_events(&mut self, cause: &str) {
        let ready = self.tasks.agenda.ready_tasks();
        if self.probed {
            let fresh: Vec<TaskId> = ready
                .iter()
                .copied()
                .filter(|task| !self.tasks.known_ready.contains(task))
                .collect();
            for task in fresh {
                self.emit_task_event(
                    TraceClass::TaskReady,
                    vec![("task", number(task.0)), ("cause", text(cause))],
                );
            }
        }
        self.tasks.known_ready = ready;
    }
}
