use serde_json::Value;
use std::io::{BufRead, BufReader, Read, Write};
use std::process::{Child, Command, Stdio};
use std::sync::mpsc::{Receiver, Sender, channel, sync_channel};
use std::time::Duration;

pub struct Session {
    child: Child,
    writer: Sender<WriteRequest>,
    responses: Receiver<Result<String, String>>,
    errors: Receiver<String>,
    pub hello: Value,
    timeout: Duration,
}

impl Session {
    pub fn start(command: &mut Command, timeout: Duration) -> Result<Self, String> {
        let mut child = command
            .stdin(Stdio::piped())
            .stdout(Stdio::piped())
            .stderr(Stdio::piped())
            .spawn()
            .map_err(|error| error.to_string())?;
        let input = child.stdin.take().ok_or("Missing adapter stdin")?;
        let output = child.stdout.take().ok_or("Missing adapter stdout")?;
        let stderr = child.stderr.take().ok_or("Missing adapter stderr")?;
        let responses = read_responses(output);
        let errors = read_errors(stderr);
        let mut session = Self {
            child,
            writer: write_requests(input),
            responses,
            errors,
            hello: Value::Null,
            timeout,
        };
        session.hello =
            session.request(&serde_json::json!({"kind":"hello","protocol":"see-protocol/1"}))?;
        validate_hello(&session.hello)?;
        Ok(session)
    }

    pub fn request(&mut self, request: &Value) -> Result<Value, String> {
        let bytes = serde_json::to_vec(request).map_err(|error| error.to_string())?;
        if bytes.len() > 1_048_576 {
            return Err("SEE-PROTOCOL: oversized request".to_owned());
        }
        let (sender, completion) = channel();
        self.writer
            .send(WriteRequest {
                bytes,
                completion: sender,
            })
            .map_err(|error| error.to_string())?;
        completion
            .recv_timeout(self.timeout)
            .map_err(|error| format!("SEE-PROTOCOL: write timeout: {error}"))??;
        let line = self
            .responses
            .recv_timeout(self.timeout)
            .map_err(|error| {
                let stderr = self
                    .errors
                    .recv_timeout(Duration::from_millis(100))
                    .unwrap_or_default();
                format!("SEE-PROTOCOL: adapter timeout or EOF: {error}; stderr: {stderr}")
            })??;
        let response: Value = serde_json::from_str(&line)
            .map_err(|error| format!("SEE-PROTOCOL: malformed JSON: {error}"))?;
        if response.get("kind") != request.get("kind") {
            return Err("SEE-PROTOCOL: response kind mismatch".to_owned());
        }
        if response.get("error").is_some() {
            return Err(format!("SEE-PROTOCOL: adapter error {response}"));
        }
        Ok(response)
    }

    pub fn finish(&mut self) -> Result<String, String> {
        self.request(&serde_json::json!({"kind":"shutdown"}))?;
        let deadline = std::time::Instant::now()
            .checked_add(self.timeout)
            .ok_or("SEE-PROTOCOL: time overflow")?;
        while self
            .child
            .try_wait()
            .map_err(|error| error.to_string())?
            .is_none()
        {
            if std::time::Instant::now() >= deadline {
                return Err("SEE-PROTOCOL: shutdown timeout".to_owned());
            }
            std::thread::sleep(Duration::from_millis(10));
        }
        if self
            .child
            .try_wait()
            .map_err(|error| error.to_string())?
            .is_some_and(|status| !status.success())
        {
            return Err("SEE-PROTOCOL: adapter exited unsuccessfully".to_owned());
        }
        self.errors
            .recv_timeout(self.timeout)
            .map_err(|error| error.to_string())
    }
}

impl Drop for Session {
    fn drop(&mut self) {
        let _killed = self.child.kill();
        let _waited = self.child.wait();
    }
}

fn read_responses(output: std::process::ChildStdout) -> Receiver<Result<String, String>> {
    let (sender, receiver) = sync_channel(4);
    std::thread::spawn(move || {
        let mut reader = BufReader::new(output);
        loop {
            let mut line = String::new();
            let result = reader.by_ref().take(1_048_577).read_line(&mut line);
            let response = match result {
                Ok(0) => break,
                Ok(length) if length > 1_048_576 => {
                    Err("SEE-PROTOCOL: oversized response".to_owned())
                }
                Ok(_) => Ok(line),
                Err(error) => Err(error.to_string()),
            };
            if sender.send(response).is_err() {
                break;
            }
        }
    });
    receiver
}

fn read_errors(stderr: std::process::ChildStderr) -> Receiver<String> {
    let (sender, receiver) = channel();
    std::thread::spawn(move || {
        let mut text = String::new();
        let outcome = stderr.take(1_048_576).read_to_string(&mut text);
        if let Err(error) = outcome {
            text.push_str(&error.to_string());
        }
        let _sent = sender.send(text);
    });
    receiver
}

fn validate_hello(hello: &Value) -> Result<(), String> {
    if hello.get("protocol").and_then(Value::as_str) != Some("see-protocol/1") {
        return Err("SEE-PROTOCOL: incompatible version".to_owned());
    }
    for name in ["subject", "subject_version"] {
        if !hello
            .get(name)
            .and_then(Value::as_str)
            .is_some_and(|value| !value.is_empty())
        {
            return Err(format!("SEE-PROTOCOL: missing {name}"));
        }
    }
    for name in ["capabilities", "profiles", "strictness"] {
        if !hello
            .get(name)
            .and_then(Value::as_array)
            .is_some_and(|values| values.iter().all(Value::is_string))
        {
            return Err(format!("SEE-PROTOCOL: missing {name}"));
        }
    }
    Ok(())
}

struct WriteRequest {
    bytes: Vec<u8>,
    completion: Sender<Result<(), String>>,
}

fn write_requests(mut input: std::process::ChildStdin) -> Sender<WriteRequest> {
    let (sender, receiver) = channel::<WriteRequest>();
    std::thread::spawn(move || {
        for request in receiver {
            let result = input
                .write_all(&request.bytes)
                .and_then(|_| input.write_all(b"\n"))
                .and_then(|_| input.flush())
                .map_err(|error| error.to_string());
            if request.completion.send(result).is_err() {
                break;
            }
        }
    });
    sender
}
