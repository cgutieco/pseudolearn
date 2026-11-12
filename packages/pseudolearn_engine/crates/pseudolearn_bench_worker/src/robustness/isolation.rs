use serde_json::{Value, json};
use std::process::{Child, Command, Stdio};
use std::time::{Duration, Instant};

const CHILD_TIMEOUT: Duration = Duration::from_secs(120);
const CHILD_MEMORY_LIMIT_KIB: u64 = 1024 * 1024;
const POLL_INTERVAL: Duration = Duration::from_millis(20);

pub struct Slice<'campaign> {
    pub campaign: &'campaign str,
    pub seed: u64,
    pub start: u64,
    pub length: u64,
}

pub fn run_slice(slice: &Slice<'_>) -> Value {
    let executable = match std::env::current_exe() {
        Ok(path) => path,
        Err(error) => return json!({"crash":error.to_string()}),
    };
    let child = Command::new(executable)
        .args([
            "robust-child",
            slice.campaign,
            &slice.seed.to_string(),
            &slice.start.to_string(),
            &slice.length.to_string(),
        ])
        .stdout(Stdio::piped())
        .stderr(Stdio::null())
        .spawn();
    let Ok(mut child) = child else {
        return json!({"crash":"spawn failed"});
    };
    if let Some(reason) = wait_within_limits(&mut child) {
        return json!({"crash":reason});
    }
    let output = child.wait_with_output();
    match output {
        Ok(result) if result.status.success() => {
            serde_json::from_slice(&result.stdout).unwrap_or(json!({"crash":"unreadable output"}))
        }
        Ok(result) => json!({"crash":format!("exit status {}", result.status)}),
        Err(error) => json!({"crash":error.to_string()}),
    }
}

fn resident_kib(process: u32) -> u64 {
    Command::new("ps")
        .args(["-o", "rss=", "-p", &process.to_string()])
        .output()
        .ok()
        .and_then(|result| String::from_utf8(result.stdout).ok())
        .and_then(|text| text.trim().parse().ok())
        .unwrap_or(0)
}

fn wait_within_limits(child: &mut Child) -> Option<String> {
    let started = Instant::now();
    loop {
        match child.try_wait() {
            Ok(Some(_)) => return None,
            Ok(None) => {}
            Err(error) => return Some(error.to_string()),
        }
        let exceeded = if started.elapsed() > CHILD_TIMEOUT {
            Some("timeout")
        } else if resident_kib(child.id()) > CHILD_MEMORY_LIMIT_KIB {
            Some("memory limit")
        } else {
            None
        };
        if let Some(reason) = exceeded {
            let _ = child.kill();
            let _ = child.wait();
            return Some(reason.to_owned());
        }
        std::thread::sleep(POLL_INTERVAL);
    }
}

pub fn isolate_crash(slice: &Slice<'_>, findings: &mut Vec<Value>) {
    if slice.length == 1 {
        findings.push(json!({"kind":"process_crash","campaign":slice.campaign,
            "seed":slice.seed,"case":slice.start}));
        return;
    }
    let half = slice.length / 2;
    let halves = [
        Slice {
            campaign: slice.campaign,
            seed: slice.seed,
            start: slice.start,
            length: half,
        },
        Slice {
            campaign: slice.campaign,
            seed: slice.seed,
            start: slice.start.saturating_add(half),
            length: slice.length.saturating_sub(half),
        },
    ];
    for part in &halves {
        if run_slice(part).get("crash").is_some() {
            isolate_crash(part, findings);
        }
    }
}
