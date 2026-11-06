use std::collections::BTreeSet;
use std::sync::{Condvar, Mutex};

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub(crate) enum Turn {
    Run,
    Exit,
}

#[derive(Default)]
struct BatonState {
    holder: u64,
    exiting: BTreeSet<u64>,
}

#[derive(Default)]
pub(crate) struct Baton {
    state: Mutex<BatonState>,
    signal: Condvar,
}

impl Baton {
    pub(crate) fn hand_to(&self, task: u64) {
        if let Ok(mut state) = self.state.lock() {
            state.holder = task;
        }
        self.signal.notify_all();
    }

    pub(crate) fn dismiss(&self, task: u64) {
        if let Ok(mut state) = self.state.lock() {
            state.exiting.insert(task);
        }
        self.signal.notify_all();
    }

    pub(crate) fn wait_for(&self, task: u64) -> Turn {
        let Ok(mut state) = self.state.lock() else {
            return Turn::Exit;
        };
        loop {
            if state.exiting.remove(&task) {
                return Turn::Exit;
            }
            if state.holder == task {
                return Turn::Run;
            }
            state = match self.signal.wait(state) {
                Ok(next) => next,
                Err(_) => return Turn::Exit,
            };
        }
    }
}
