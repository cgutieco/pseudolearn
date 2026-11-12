#![forbid(unsafe_code)]

use std::collections::BTreeMap;

use pseudolearn_bytecode::Opcode;

use crate::load::LoadedFunction;

#[derive(Clone, Debug, Default, Eq, PartialEq)]
pub struct OpcodeProfile {
    pub opcode_counts: BTreeMap<String, u64>,
    pub pair_counts: BTreeMap<String, u64>,
    last_opcode: Option<String>,
}

pub(crate) trait OpcodeObserver {
    fn record(&mut self, function: &LoadedFunction, position: usize);
}

pub(crate) struct NoOpcodeObserver;

impl OpcodeObserver for NoOpcodeObserver {
    #[inline(always)]
    fn record(&mut self, _function: &LoadedFunction, _position: usize) {}
}

impl OpcodeObserver for OpcodeProfile {
    fn record(&mut self, function: &LoadedFunction, position: usize) {
        let Some(origin) = function.origins.get(position) else {
            return;
        };
        for opcode in [origin.first, origin.second].into_iter().flatten() {
            self.count(opcode);
        }
    }
}

impl OpcodeProfile {
    fn count(&mut self, opcode: Opcode) {
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
