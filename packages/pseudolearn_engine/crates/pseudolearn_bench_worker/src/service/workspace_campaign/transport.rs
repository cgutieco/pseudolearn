use crate::service::workspace_campaign::framing::{read_message, write_message};
use serde_json::Value;
use std::io::BufReader;
use std::process::{Child, ChildStdin, ChildStdout, Command, Stdio};

pub trait Transport {
    fn send(&mut self, message: &Value) -> Result<(), String>;
    fn receive(&mut self) -> Result<Value, String>;
}

pub struct ProcessTransport {
    child: Child,
    input: ChildStdin,
    output: BufReader<ChildStdout>,
}

impl ProcessTransport {
    pub fn spawn(binary: &str) -> Result<Self, String> {
        let mut child = Command::new(binary)
            .arg("lsp")
            .stdin(Stdio::piped())
            .stdout(Stdio::piped())
            .stderr(Stdio::null())
            .spawn()
            .map_err(|error| format!("cannot start {binary}: {error}"))?;
        let input = child.stdin.take().ok_or("missing child stdin")?;
        let output = child.stdout.take().ok_or("missing child stdout")?;
        Ok(Self {
            child,
            input,
            output: BufReader::new(output),
        })
    }
}

impl Transport for ProcessTransport {
    fn send(&mut self, message: &Value) -> Result<(), String> {
        write_message(&mut self.input, message)
    }

    fn receive(&mut self) -> Result<Value, String> {
        read_message(&mut self.output)
    }
}

impl Drop for ProcessTransport {
    fn drop(&mut self) {
        let _ = self.child.kill();
        let _ = self.child.wait();
    }
}
