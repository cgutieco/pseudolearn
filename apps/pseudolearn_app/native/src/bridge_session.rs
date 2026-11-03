use pseudolearn_api::ApiSession;
use pseudolearn_host::HostWorker;
use serde_json::{Value, json};
use std::collections::BTreeMap;

#[derive(Default)]
pub(crate) struct BridgeSession {
    api: ApiSession,
    hosts: BTreeMap<u64, HostWorker>,
}

impl BridgeSession {
    pub(crate) fn call(&mut self, operation: &str, arguments: &Value) -> Value {
        if operation.starts_with("host_") {
            return match self.host_call(operation, arguments) {
                Ok(value) => json!({"value":value}),
                Err(detail) => json!({"failure":{"family":"usage","detail":detail}}),
            };
        }
        if matches!(operation, "cancel" | "release")
            && let Some(resource) = arguments.get("resource").and_then(Value::as_u64)
        {
            self.hosts.remove(&resource);
        }
        let prepared = if operation == "start" {
            prepare_start(arguments)
        } else {
            Ok(arguments.clone())
        };
        match prepared {
            Ok(arguments) => self.api.call(operation, &arguments),
            Err(detail) => json!({"failure":{"family":"usage","detail":detail}}),
        }
    }

    fn host_call(&mut self, operation: &str, arguments: &Value) -> Result<Value, String> {
        let resource = arguments
            .get("resource")
            .and_then(Value::as_u64)
            .ok_or("missing resource")?;
        if operation == "host_close" {
            self.hosts.remove(&resource);
            return Ok(Value::Null);
        }
        if operation == "host_open" {
            self.hosts.insert(resource, open_host(arguments)?);
            return Ok(Value::Null);
        }
        let host = self.hosts.get_mut(&resource).ok_or("host is closed")?;
        match operation {
            "host_submit" => {
                host.submit(arguments.get("effect").ok_or("missing effect")?)?;
                Ok(Value::Null)
            }
            "host_poll" => Ok(json!(host.poll())),
            _ => Err("unknown host operation".to_owned()),
        }
    }
}

fn prepare_start(arguments: &Value) -> Result<Value, String> {
    let mut arguments = arguments.clone();
    let seed =
        if arguments.get("execution_mode").and_then(Value::as_str) == Some("replay_from_tape") {
            arguments.pointer("/effect_tape/identity/seed").cloned()
        } else if arguments.get("seed").is_none() {
            Some(json!(pseudolearn_host::entropy_seed()?))
        } else {
            None
        };
    if let Some(seed) = seed {
        arguments["seed"] = seed;
    }
    Ok(arguments)
}

fn open_host(arguments: &Value) -> Result<HostWorker, String> {
    let default_directory = std::env::current_dir().map_err(|error| error.to_string())?;
    let directory = arguments
        .get("directory")
        .and_then(Value::as_str)
        .map(std::path::PathBuf::from)
        .unwrap_or(default_directory);
    std::fs::create_dir_all(&directory).map_err(|error| error.to_string())?;
    let supplied = arguments
        .get("args")
        .and_then(Value::as_array)
        .ok_or("missing arguments")?;
    let supplied = supplied
        .iter()
        .map(|value| {
            value
                .as_str()
                .map(str::to_owned)
                .ok_or_else(|| "invalid argument".to_owned())
        })
        .collect::<Result<Vec<_>, _>>()?;
    HostWorker::new(directory, supplied)
}
