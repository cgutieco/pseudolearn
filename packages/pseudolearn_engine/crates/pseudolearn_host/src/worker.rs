use crate::PhysicalHost;
use serde_json::{Value, json};
use std::collections::BTreeSet;
use std::path::PathBuf;
use std::sync::{
    Arc,
    atomic::{AtomicBool, Ordering},
    mpsc,
};

pub struct HostWorker {
    sender: Option<mpsc::SyncSender<Value>>,
    receiver: mpsc::Receiver<Value>,
    cancellation: Arc<AtomicBool>,
    pending: BTreeSet<u64>,
}

impl HostWorker {
    pub fn new(directory: PathBuf, arguments: Vec<String>) -> Result<Self, String> {
        Self::from_host(PhysicalHost::new(directory, arguments))
    }

    pub fn from_host(host: PhysicalHost) -> Result<Self, String> {
        let (sender, requests) = mpsc::sync_channel(32);
        let (replies, receiver) = mpsc::sync_channel(32);
        let cancellation = host.cancellation();
        std::thread::Builder::new()
            .name("pseudolearn-host".to_owned())
            .spawn(move || run(host, requests, replies))
            .map_err(|error| error.to_string())?;
        Ok(Self {
            sender: Some(sender),
            receiver,
            cancellation,
            pending: BTreeSet::new(),
        })
    }

    pub fn submit(&mut self, effect: &Value) -> Result<(), String> {
        let sequence = effect
            .get("effect_seq")
            .and_then(Value::as_u64)
            .ok_or("missing effect sequence")?;
        if self.pending.contains(&sequence) {
            return Ok(());
        }
        if self.pending.len() >= 32 {
            return Err("host queue is full".to_owned());
        }
        self.sender
            .as_ref()
            .ok_or("host is closed")?
            .try_send(effect.clone())
            .map_err(|error| error.to_string())?;
        self.pending.insert(sequence);
        Ok(())
    }

    pub fn poll(&mut self) -> Vec<Value> {
        let mut results = Vec::new();
        while let Ok(reply) = self.receiver.try_recv() {
            if let Some(sequence) = reply.get("effect_seq").and_then(Value::as_u64) {
                self.pending.remove(&sequence);
            }
            results.push(reply);
        }
        results
    }
}

impl Drop for HostWorker {
    fn drop(&mut self) {
        self.cancellation.store(true, Ordering::SeqCst);
        self.sender.take();
    }
}

fn run(mut host: PhysicalHost, requests: mpsc::Receiver<Value>, replies: mpsc::SyncSender<Value>) {
    while let Ok(effect) = requests.recv() {
        if host.cancellation().load(Ordering::SeqCst) {
            break;
        }
        let independent = matches!(
            effect.get("operation").and_then(Value::as_str),
            Some("network_send" | "timer_wait")
        );
        if independent {
            let mut independent_host = host.fork();
            let sender = replies.clone();
            let sequence = effect.get("effect_seq").cloned();
            let spawned = std::thread::Builder::new()
                .name("pseudolearn-effect".to_owned())
                .spawn(move || deliver(&mut independent_host, effect, &sender));
            if spawned.is_err() {
                let _delivered = replies.send(json!({"effect_seq":sequence,
                    "result":crate::HostError::INTERRUPTED.reply()}));
            }
        } else {
            deliver(&mut host, effect, &replies);
        }
    }
}

fn deliver(host: &mut PhysicalHost, effect: Value, replies: &mpsc::SyncSender<Value>) {
    let result = host.perform(&effect);
    let _delivered = replies.send(json!({"effect_seq":effect.get("effect_seq"), "result":result}));
}
