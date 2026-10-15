#![forbid(unsafe_code)]

use std::collections::BTreeMap;

use pseudolearn_bytecode::Opcode;

use crate::{DispatchKind, dispatch_kind};

#[derive(Clone, Debug, Default, Eq, PartialEq)]
pub struct OpcodeProfile {
    pub opcode_counts: BTreeMap<String, u64>,
    pub pair_counts: BTreeMap<String, u64>,
    last_opcode: Option<String>,
}

pub(crate) trait OpcodeObserver {
    fn record(&mut self, opcode: Opcode);
}

pub(crate) struct NoOpcodeObserver;

impl OpcodeObserver for NoOpcodeObserver {
    fn record(&mut self, _opcode: Opcode) {}
}

impl OpcodeObserver for OpcodeProfile {
    fn record(&mut self, opcode: Opcode) {
        if dispatch_kind(opcode) == DispatchKind::Observation {
            return;
        }
        let name = format!("{opcode:?}");
        let count = self.opcode_counts.entry(name.clone()).or_default();
        *count = count.saturating_add(1);
        if let Some(previous) = &self.last_opcode {
            let pair = self
                .pair_counts
                .entry(format!("{previous}->{name}"))
                .or_default();
            *pair = pair.saturating_add(1);
        }
        self.last_opcode = Some(name);
    }
}
