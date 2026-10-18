use crate::config::{AotConfig, AotStreams};
use crate::context::AotRuntimeContext;
use crate::engine::AotEngine;
use crate::fault::FaultSite;

pub struct AotSession {
    engine: Box<AotEngine>,
    context: Box<AotRuntimeContext>,
}

impl AotSession {
    pub fn new(config: AotConfig, sites: Vec<FaultSite>, streams: AotStreams) -> Self {
        let limits = config.limits;
        let mut engine = Box::new(AotEngine::new(config, sites, streams));
        let budget = limits
            .instruction_units
            .map_or(i64::MAX, |units| i64::try_from(units).unwrap_or(i64::MAX));
        let context = Box::new(AotRuntimeContext {
            heap_words_pointer: engine.heap.words_pointer(),
            instruction_remaining: budget,
            frame_depth: 0,
            frame_limit: limits.frames,
            root_top: 0,
            root_capacity: limits.root_capacity,
            roots_pointer: engine.roots.as_mut_ptr(),
            fault_site: 0,
            fault_status: 0,
            result_word: 0,
            engine_state: &mut *engine,
            cells_pointer: engine.cells.as_ptr().cast(),
            cells_length: 0,
            heap_used: 0,
            heap_limit: 0,
            heap_ordinal: 0,
            room_cells: 0,
            room_threshold: 0,
            free_size_mask: 0,
            pending_pointer: std::ptr::null_mut(),
            pending_length: 0,
            pending_capacity: 0,
        });
        let mut session = Self { engine, context };
        session.engine.publish_inline(&mut session.context);
        session
    }

    pub fn context_pointer(&mut self) -> *mut AotRuntimeContext {
        &mut *self.context
    }

    pub fn context(&self) -> &AotRuntimeContext {
        &self.context
    }

    pub fn engine(&self) -> &AotEngine {
        &self.engine
    }

    pub fn engine_mut(&mut self) -> &mut AotEngine {
        &mut self.engine
    }

    pub fn push_root(&mut self, handle: u32) -> bool {
        let Ok(top) = usize::try_from(self.context.root_top) else {
            return false;
        };
        let Some(slot) = self.engine.roots.get_mut(top) else {
            return false;
        };
        *slot = handle;
        self.context.root_top = self.context.root_top.saturating_add(1);
        true
    }

    pub fn pop_roots(&mut self, count: u32) {
        self.context.root_top = self.context.root_top.saturating_sub(count);
    }
}

pub fn settle_session(session: &mut AotSession) -> bool {
    session.engine.settle_inline(&mut session.context).is_ok()
}
