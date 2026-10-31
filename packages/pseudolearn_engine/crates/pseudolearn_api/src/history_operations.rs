use super::{ExecutionResource, usage};
use crate::ApiError;
use pseudolearn_vm::{TraceClass, machine_output};
use serde_json::{Value, json};

impl ExecutionResource {
    pub(crate) fn history_events(&self, arguments: &Value) -> Result<Value, ApiError> {
        let (start, count, backward) = history_request(arguments)?;
        let first = self.retained_start.max(self.store.stats().horizon);
        if start < first || start >= self.delivered {
            return Err(usage("event outside retained horizon"));
        }
        let length = if backward {
            count.min(start.saturating_sub(first).saturating_add(1))
        } else {
            count.min(self.delivered.saturating_sub(start))
        };
        let lower = if backward {
            start.saturating_add(1).saturating_sub(length)
        } else {
            start
        };
        let mut events = self.history_window(lower, length)?;
        if backward {
            events.reverse();
        }
        Ok(
            json!({"events":events.iter().map(|event| self.sources.event(&event.event)).collect::<Vec<_>>(),
            "first":lower,"count":length,"horizon":self.horizon()}),
        )
    }

    fn boundary_event(
        &self,
        start: usize,
    ) -> Result<pseudolearn_timeline::HistoricalEvent, ApiError> {
        let (event, task) = self
            .store
            .boundary_event(start)
            .cloned()
            .ok_or_else(|| usage("unreachable history boundary"))?;
        Ok(pseudolearn_timeline::HistoricalEvent { event, task })
    }

    fn history_window(
        &self,
        start: usize,
        count: usize,
    ) -> Result<Vec<pseudolearn_timeline::HistoricalEvent>, ApiError> {
        if count == 0 {
            return Ok(Vec::new());
        }
        let end = start
            .checked_add(count)
            .ok_or_else(|| usage("history range overflow"))?;
        let (image, _) = self
            .store
            .image_at(start.saturating_sub(1))
            .or_else(|_| self.store.image_at(start))
            .map_err(|_| usage("event outside retained horizon"))?;
        let after = image.state.event_count;
        let mut events = Vec::new();
        if after > start {
            if after != start.saturating_add(1) {
                return Err(usage("unreachable history boundary"));
            }
            events.push(self.boundary_event(start)?);
        }
        if end > after {
            let begin = start.max(after);
            let mut options = self.options.clone();
            options.cancelled = None;
            events.extend(
                pseudolearn_timeline::replay_event_window(
                    &self.program,
                    image,
                    (begin, end.saturating_sub(begin)),
                    (&options, self.effects.tape()),
                )
                .map_err(|_| usage("unreachable historical event"))?,
            );
        }
        Ok(events)
    }

    fn observe_history(
        &mut self,
        start: usize,
        events: Vec<(usize, pseudolearn_timeline::HistoricalEvent)>,
        backward: bool,
    ) -> Result<(), ApiError> {
        for (offset, event) in events {
            let index = start.saturating_add(offset);
            let task = event.task;
            let event = event.event;
            let debug = self
                .debug
                .as_mut()
                .ok_or_else(|| usage("debugging not configured"))?;
            if backward && event.class == TraceClass::StatementEntered {
                debug.last = Some(event);
                debug.cursor = Some(index);
                debug.stop("step", task);
            } else {
                debug.observe(&event, task, index);
            }
            if debug.stopped {
                debug.history_direction = None;
                break;
            }
        }
        Ok(())
    }

    pub(super) fn advance_history(&mut self, maximum: usize) -> Result<Value, ApiError> {
        if maximum == 0 || maximum > 4096 {
            return Err(usage("invalid debug batch size"));
        }
        let debug = self
            .debug
            .as_ref()
            .ok_or_else(|| usage("debugging not configured"))?;
        let backward = debug.history_direction.unwrap_or(false);
        let cursor = debug
            .cursor
            .ok_or_else(|| usage("missing historical cursor"))?;
        let first = self.retained_start.max(self.store.stats().horizon);
        let (start, count) = history_range(cursor, backward, (first, self.delivered), maximum)?;
        let mut events: Vec<_> = self
            .history_window(start, count)?
            .into_iter()
            .enumerate()
            .collect();
        if backward {
            events.reverse();
        }
        self.observe_history(start, events, backward)?;
        let tip = self.delivered.saturating_sub(1);
        if let Some(debug) = &mut self.debug
            && !debug.stopped
            && (debug.cursor == Some(first) || debug.cursor == Some(tip))
        {
            debug.history_direction = None;
            debug.stop("step", debug.task);
        }
        Ok(
            json!({"events":[],"output":machine_output(&self.machine),"termination":{"kind":"running"},"debug":self.debug_state(&json!({}))?}),
        )
    }
}

fn history_range(
    cursor: usize,
    backward: bool,
    horizon: (usize, usize),
    maximum: usize,
) -> Result<(usize, usize), ApiError> {
    if backward {
        if cursor <= horizon.0 {
            return Err(usage("event outside retained horizon"));
        }
        let count = maximum.min(cursor.saturating_sub(horizon.0));
        Ok((cursor.saturating_sub(count), count))
    } else {
        let start = cursor
            .checked_add(1)
            .ok_or_else(|| usage("history range overflow"))?;
        Ok((start, maximum.min(horizon.1.saturating_sub(start))))
    }
}

fn history_request(arguments: &Value) -> Result<(usize, usize, bool), ApiError> {
    let index = |name: &str| {
        arguments
            .get(name)
            .and_then(Value::as_u64)
            .and_then(|number| usize::try_from(number).ok())
            .ok_or_else(|| usage("invalid history range"))
    };
    let start = index("start")?;
    let count = index("count")?;
    if count > 4096 {
        return Err(usage("history window exceeds limit"));
    }
    let backward = match arguments
        .get("direction")
        .and_then(Value::as_str)
        .unwrap_or("forward")
    {
        "forward" => false,
        "backward" => true,
        _ => return Err(usage("invalid history direction")),
    };
    Ok((start, count, backward))
}
