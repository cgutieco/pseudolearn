use crate::cells::rooted_handles;
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
        self.context.cells_pointer = self.engine.cells.as_ptr().cast();
        self.context.cells_length = u64::try_from(self.engine.cells.len()).unwrap_or(0);
    }

    pub(crate) fn allocation_roots(&self, cells: u64) -> Result<Vec<Handle>, Trap> {
        if self.engine.heap.needs_collection(cells) {
            self.roots()
        } else {
            Ok(Vec::new())
        }
    }

    pub(crate) fn roots(&self) -> Result<Vec<Handle>, Trap> {
        #[cfg(feature = "telemetry")]
        self.engine.record(|statistics| {
            statistics.root_builds = statistics.root_builds.saturating_add(1);
            statistics.root_cells_scanned = statistics
                .root_cells_scanned
                .saturating_add(u64::try_from(self.engine.cells.len()).unwrap_or(u64::MAX));
        });
        let top =
            usize::try_from(self.context.root_top).map_err(|_| Trap::named("internalFault"))?;
        let words = self
            .engine
            .roots
            .get(..top)
            .ok_or_else(|| Trap::named("internalFault"))?;
        let mut handles: Vec<Handle> = words.iter().copied().map(Handle).collect();
        handles.extend(rooted_handles(&self.engine.cells));
        Ok(handles)
    }

    fn fail(&mut self, mut trap: Trap) -> u32 {
        if matches!(
            trap.code.map(|code| code.as_str()),
            Some("uninitializedVariableRead" | "subroutineEndedWithoutReturn")
        ) && !trap.arguments.iter().any(|(name, _)| name == "lexeme")
            && let Some(lexeme) = self.engine.site_lexeme(self.site)
        {
            trap = trap.argument("lexeme", lexeme);
        }
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
