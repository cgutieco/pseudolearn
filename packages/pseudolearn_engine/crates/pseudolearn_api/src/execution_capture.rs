use crate::{ApiError, ExecuteRequest};
use pseudolearn_vm::{LimitKind, Machine, RunExit, machine_events};
use serde_json::Value;

pub(crate) struct Captured {
    pub(crate) exit: RunExit,
    pub(crate) state: Option<Value>,
    pub(crate) page: Option<Result<Value, ApiError>>,
}

pub(crate) fn run_capturing(machine: &mut Machine<'_>, request: &ExecuteRequest) -> Captured {
    let page_request = request
        .state_page
        .as_ref()
        .map(crate::state_pages::PageRequest::parse);
    let mut captured = Captured {
        exit: RunExit::LimitReached {
            kind: LimitKind::Time,
        },
        state: None,
        page: None,
    };
    let mut previous_count = 0;
    loop {
        let outcome = machine.step_instruction();
        let count = machine_events(machine).len();
        let produced_event = count > previous_count;
        let within_step = |event: usize| event >= previous_count && event < count;
        if request.state_at.is_some_and(within_step) && produced_event {
            captured.state = Some(crate::execution_state::capture(machine));
        }
        if let Some(Ok(page)) = &page_request
            && within_step(page.event)
            && produced_event
        {
            captured.page = Some(crate::state_pages::page(machine, page, "execute"));
        }
        previous_count = count;
        if let Some(exit) = outcome {
            captured.exit = exit;
            return captured;
        }
    }
}
