use crate::physical_host::PhysicalHost;
use pseudolearn_host::HostWorker;
use serde_json::Value;
use std::collections::BTreeMap;

pub(crate) struct EffectHost {
    worker: HostWorker,
    pending: BTreeMap<u64, Value>,
}

impl EffectHost {
    pub(crate) fn new(host: PhysicalHost) -> Result<Self, String> {
        Ok(Self {
            worker: HostWorker::from_host(host)?,
            pending: BTreeMap::new(),
        })
    }

    pub(crate) fn submit(&mut self, request: Value) -> Result<bool, String> {
        let sequence = request
            .get("effect_seq")
            .and_then(Value::as_u64)
            .ok_or("missing effect sequence")?;
        if self.pending.contains_key(&sequence) {
            return Ok(false);
        }
        self.worker.submit(&request)?;
        self.pending.insert(sequence, request);
        Ok(true)
    }

    pub(crate) fn completed(&mut self) -> Vec<(Value, Value)> {
        self.worker
            .poll()
            .into_iter()
            .filter_map(|reply| {
                let sequence = reply.get("effect_seq")?.as_u64()?;
                let request = self.pending.remove(&sequence)?;
                Some((request, reply.get("result")?.clone()))
            })
            .collect()
    }

    pub(crate) fn is_pending(&self) -> bool {
        !self.pending.is_empty()
    }

    pub(crate) fn close(self) {
        drop(self);
    }
}
