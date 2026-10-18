use crate::context::{AotRuntimeContext, STATUS_CONTINUE, STATUS_FAILED};
use crate::engine::AotEngine;
use crate::fault::{FaultRecord, status_of};
use crate::trap::Trap;
use pseudolearn_abi::Handle;

pub(crate) struct Entry<'engine> {
    pub(crate) context: &'engine mut AotRuntimeContext,
    pub(crate) engine: &'engine mut AotEngine,
    pub(crate) site: u32,
}

fn open_entry<'engine>(context: *mut AotRuntimeContext, site: u32) -> Option<Entry<'engine>> {
    let context = unsafe { context.as_mut() }?;
    let engine = unsafe { context.engine_state.as_mut() }?;
    Some(Entry {
        context,
        engine,
        site,
    })
}

pub(crate) fn borrow_slice<'span, Element>(
    pointer: *const Element,
    count: usize,
) -> Option<&'span [Element]> {
    match (count, pointer.is_null()) {
        (0, _) => Some(&[]),
        (_, true) => None,
        _ => Some(unsafe { std::slice::from_raw_parts(pointer, count) }),
    }
}

pub(crate) fn run_entry(
    context: *mut AotRuntimeContext,
    site: u32,
    operation: impl FnOnce(&mut Entry<'_>) -> Result<u64, Trap>,
) -> u32 {
    let Some(mut entry) = open_entry(context, site) else {
        return STATUS_FAILED;
    };
    match operation(&mut entry) {
        Ok(word) => {
            entry.context.result_word = word;
            entry.refresh();
            STATUS_CONTINUE
        }
        Err(trap) => entry.fail(trap),
    }
}

impl Entry<'_> {
    pub(crate) fn refresh(&mut self) {
        self.context.heap_words_pointer = self.engine.heap.words_pointer();
    }

    pub(crate) fn roots(&self) -> Result<Vec<Handle>, Trap> {
        let top =
            usize::try_from(self.context.root_top).map_err(|_| Trap::named("internalFault"))?;
        let words = self
            .engine
            .roots
            .get(..top)
            .ok_or_else(|| Trap::named("internalFault"))?;
        Ok(words.iter().copied().map(Handle).collect())
    }

    fn fail(&mut self, trap: Trap) -> u32 {
        let status = status_of(trap.code);
        self.engine.record_fault(FaultRecord {
            site: self.site,
            code: trap.code,
            range: self.engine.site_range(self.site),
            arguments: trap.arguments,
        });
        self.context.fault_site = self.site;
        self.context.fault_status = status;
        self.refresh();
        status
    }
}
