use serde_json::{Value, json};
use std::process::Command;

fn capture(program: &str, arguments: &[&str]) -> String {
    Command::new(program)
        .args(arguments)
        .output()
        .map(|output| String::from_utf8_lossy(&output.stdout).trim().to_owned())
        .unwrap_or_default()
}

pub fn describe() -> Value {
    let seconds = std::time::SystemTime::now()
        .duration_since(std::time::UNIX_EPOCH)
        .map_or(0, |elapsed| elapsed.as_secs());
    json!({
        "commit": capture("git", &["rev-parse", "HEAD"]),
        "dirty": !capture("git", &["status", "--porcelain"]).is_empty(),
        "rustc": capture("rustc", &["--version", "--verbose"]),
        "operatingSystem": std::env::consts::OS,
        "architecture": std::env::consts::ARCH,
        "hardware": capture("sysctl", &["-n", "machdep.cpu.brand_string"]),
        "unixSeconds": seconds,
        "processesPerWorkload": 10,
        "iterationsPerProcess": super::measurement::ITERATIONS,
    })
}
