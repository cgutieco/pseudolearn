use crate::physical_host::PhysicalHost;
use serde_json::{Value, json};
use std::collections::BTreeSet;
use std::sync::Arc;
use std::sync::atomic::{AtomicBool, Ordering};
use std::sync::mpsc::{Receiver, SyncSender, sync_channel};

pub(crate) struct EffectHost {
    sender: SyncSender<Value>,
    receiver: Receiver<(Value, Value)>,
    cancelled: Arc<AtomicBool>,
    pending: BTreeSet<u64>,
}

impl EffectHost {
    pub(crate) fn new(mut host: PhysicalHost) -> Self {
        let (sender, requests) = sync_channel::<Value>(8);
        let (replies, receiver) = sync_channel(8);
        let cancelled = Arc::new(AtomicBool::new(false));
        let cancellation = cancelled.clone();
        std::thread::spawn(move || {
            while let Ok(request) = requests.recv() {
                if cancellation.load(Ordering::SeqCst) {
                    break;
                }
                if request.get("operation").and_then(Value::as_str) == Some("network_send") {
                    dispatch_network(request, &host, &replies, &cancellation);
                    continue;
                }
                let reply = perform(&mut host, &request, &cancellation);
                if replies.send((request, reply)).is_err() {
                    break;
                }
            }
        });
        Self {
            sender,
            receiver,
            cancelled,
            pending: BTreeSet::new(),
        }
    }

    pub(crate) fn submit(&mut self, request: Value) -> Result<bool, String> {
        let sequence = request
            .get("effect_seq")
            .and_then(Value::as_u64)
            .ok_or("missing effect sequence")?;
        if self.pending.contains(&sequence) {
            return Ok(false);
        }
        if self.pending.len() >= 8 {
            return Err("physical effect queue exceeded eight requests".to_owned());
        }
        self.sender
            .try_send(request)
            .map_err(|_| "physical effect worker is unavailable".to_owned())?;
        self.pending.insert(sequence);
        Ok(true)
    }

    pub(crate) fn completed(&mut self) -> Vec<(Value, Value)> {
        let replies = self.receiver.try_iter().collect::<Vec<_>>();
        for (request, _) in &replies {
            if let Some(sequence) = request.get("effect_seq").and_then(Value::as_u64) {
                self.pending.remove(&sequence);
            }
        }
        replies
    }

    pub(crate) fn is_pending(&self) -> bool {
        !self.pending.is_empty()
    }

    pub(crate) fn close(self) {
        self.cancelled.store(true, Ordering::SeqCst);
    }
}

fn dispatch_network(
    request: Value,
    host: &PhysicalHost,
    replies: &SyncSender<(Value, Value)>,
    cancellation: &Arc<AtomicBool>,
) {
    let replies = replies.clone();
    let policy = host.network_policy().clone();
    let cancellation = cancellation.clone();
    std::thread::spawn(move || {
        let reply =
            crate::physical_network_send::perform_cancellable(&request, &policy, cancellation);
        let _ = replies.send((request, reply));
    });
}

fn perform(host: &mut PhysicalHost, request: &Value, cancellation: &Arc<AtomicBool>) -> Value {
    match request.get("operation").and_then(Value::as_str) {
        Some("network_send") => crate::physical_network_send::perform_cancellable(
            request,
            host.network_policy(),
            cancellation.clone(),
        ),
        Some("console_write") => {
            let text = request
                .pointer("/arguments/0/value")
                .and_then(Value::as_str)
                .unwrap_or("");
            let length = i64::try_from(text.len()).unwrap_or(i64::MAX);
            crate::physical_error::committed("integer", json!(length))
        }
        _ => host.perform(request),
    }
}
