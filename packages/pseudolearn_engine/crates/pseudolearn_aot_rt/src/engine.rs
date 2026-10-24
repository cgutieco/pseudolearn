use crate::cells::CellSlot;
use crate::config::{AotConfig, AotStreams, BooleanWords};
use crate::fault::{FaultRecord, FaultSite, SourceRange};
use crate::trap::Trap;
use pseudolearn_diagnostics::DiagnosticCode;
use pseudolearn_runtime::{
    CollectionPolicy, Heap, MemoryError, MemoryOptions, ObjectLayout, RandomState,
};
use std::sync::Arc;

pub struct AotEngine {
    #[cfg(feature = "telemetry")]
    pub(crate) statistics: std::cell::Cell<crate::AotStatistics>,
    pub(crate) heap: Heap,
    pub(crate) random: RandomState,
    pub(crate) layouts: Vec<Option<Arc<ObjectLayout>>>,
    pub(crate) sites: Vec<FaultSite>,
    pub(crate) roots: Vec<u32>,
    pub(crate) cells: Vec<CellSlot>,
    pub(crate) pending: Vec<u64>,
    pub(crate) boolean_words: BooleanWords,
    pub(crate) site_boolean_words: Vec<BooleanWords>,
    pub(crate) streams: AotStreams,
    fault: Option<FaultRecord>,
    notices: Vec<FaultRecord>,
}

impl AotEngine {
    pub(crate) fn new(config: AotConfig, sites: Vec<FaultSite>, streams: AotStreams) -> Self {
        let capacity = usize::try_from(config.limits.root_capacity).unwrap_or(0);
        Self {
            #[cfg(feature = "telemetry")]
            statistics: std::cell::Cell::default(),
            heap: Heap::new(MemoryOptions {
                collection_minimum: 262_144,
                cells: config.limits.cells,
                collection: CollectionPolicy::Automatic,
            }),
            random: RandomState::seeded(config.seed),
            layouts: Vec::new(),
            sites,
            roots: vec![0; capacity],
            cells: Vec::new(),
            pending: vec![
                0;
                crate::inline_allocation::INLINE_PENDING_CAPACITY
                    .saturating_mul(crate::inline_allocation::INLINE_RECORD_WORDS)
            ],
            boolean_words: config.boolean_words,
            site_boolean_words: Vec::new(),
            streams,
            fault: None,
            notices: Vec::new(),
        }
    }

    pub fn use_site_boolean_words(&mut self, words: Vec<BooleanWords>) {
        self.site_boolean_words = words;
    }

    pub(crate) fn boolean_words_for(&self, profile_index: usize) -> &BooleanWords {
        self.site_boolean_words
            .get(profile_index)
            .unwrap_or(&self.boolean_words)
    }

    pub fn register_layout(&mut self, layout: ObjectLayout) -> Result<(), MemoryError> {
        let index = usize::try_from(layout.class).map_err(|_| MemoryError::Resource)?;
        let required = index.checked_add(1).ok_or(MemoryError::Resource)?;
        if self.layouts.len() < required {
            self.layouts.resize(required, None);
        }
        self.heap.register_layout(layout.clone())?;
        if let Some(slot) = self.layouts.get_mut(index) {
            *slot = Some(Arc::new(layout));
        }
        Ok(())
    }

    pub fn force_collection(&mut self) {
        self.heap.set_collection_policy(CollectionPolicy::Forced);
    }

    pub fn flush_output(&mut self) -> std::io::Result<()> {
        self.streams.output.flush()
    }

    pub fn fault(&self) -> Option<&FaultRecord> {
        self.fault.as_ref()
    }

    pub fn notices(&self) -> &[FaultRecord] {
        &self.notices
    }

    pub fn heap(&self) -> &Heap {
        &self.heap
    }

    pub(crate) fn site_lexeme(&self, site: u32) -> Option<&str> {
        self.site(site)
            .map(|site| site.lexeme.as_str())
            .filter(|name| !name.is_empty())
    }

    pub(crate) fn site_range(&self, site: u32) -> SourceRange {
        self.site(site).map(|entry| entry.range).unwrap_or_default()
    }

    pub(crate) fn site_code(&self, site: u32) -> Result<DiagnosticCode, Trap> {
        self.site(site)
            .map(|entry| entry.code)
            .ok_or_else(|| Trap::named("internalFault"))
    }

    pub(crate) fn record_fault(&mut self, record: FaultRecord) {
        if self.fault.is_none() {
            self.fault = Some(record);
        }
    }

    pub(crate) fn record_notice(&mut self, record: FaultRecord) {
        self.notices.push(record);
    }

    fn site(&self, site: u32) -> Option<&FaultSite> {
        self.sites.get(usize::try_from(site).ok()?)
    }
}
