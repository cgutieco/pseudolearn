use pseudolearn_api::{ExecuteRequest, ExecuteResponse, execute_program};
use serde_json::{Value, json};
use std::io::{BufRead, BufReader, Write};
use std::process::{Child, ChildStdin, ChildStdout, Command, Stdio};

pub trait TaskSubject {
    fn name(&self) -> &'static str;
    fn execute(&mut self, request: &ExecuteRequest) -> Result<ExecuteResponse, String>;
}

pub struct VirtualMachine;

impl TaskSubject for VirtualMachine {
    fn name(&self) -> &'static str {
        "vm"
    }

    fn execute(&mut self, request: &ExecuteRequest) -> Result<ExecuteResponse, String> {
        Ok(execute_program(request))
    }
}

pub struct NativeAdapter {
    process: Child,
    input: ChildStdin,
    output: BufReader<ChildStdout>,
}

impl NativeAdapter {
    pub fn launch(pseudo: &str) -> Result<Self, String> {
        let mut process = Command::new(pseudo)
            .args(["--see-adapter", "aot"])
            .stdin(Stdio::piped())
            .stdout(Stdio::piped())
            .stderr(Stdio::null())
            .spawn()
            .map_err(|error| format!("cannot launch {pseudo}: {error}"))?;
        let input = process.stdin.take().ok_or("adapter without stdin")?;
        let output = BufReader::new(process.stdout.take().ok_or("adapter without stdout")?);
        let mut adapter = Self {
            process,
            input,
            output,
        };
        let greeting = adapter.exchange(&json!({"kind": "hello"}))?;
        if greeting.get("subject").and_then(Value::as_str) != Some("aot") {
            return Err(format!("unexpected adapter greeting {greeting}"));
        }
        Ok(adapter)
    }

    fn exchange(&mut self, message: &Value) -> Result<Value, String> {
        writeln!(self.input, "{message}").map_err(|error| error.to_string())?;
        self.input.flush().map_err(|error| error.to_string())?;
        let mut line = String::new();
        self.output
            .read_line(&mut line)
            .map_err(|error| error.to_string())?;
        serde_json::from_str(line.trim()).map_err(|error| format!("adapter reply: {error}"))
    }
}

impl TaskSubject for NativeAdapter {
    fn name(&self) -> &'static str {
        "aot"
    }

    fn execute(&mut self, request: &ExecuteRequest) -> Result<ExecuteResponse, String> {
        let mut message = serde_json::to_value(request).map_err(|error| error.to_string())?;
        if let Some(fields) = message.as_object_mut() {
            fields.insert("kind".to_owned(), json!("execute"));
        }
        let reply = self.exchange(&message)?;
        serde_json::from_value(reply).map_err(|error| format!("adapter response: {error}"))
    }
}

impl Drop for NativeAdapter {
    fn drop(&mut self) {
        let _sent = writeln!(self.input, "{}", json!({"kind": "shutdown"}));
        let _flushed = self.input.flush();
        let _waited = self.process.wait();
    }
}

pub fn subject_from(arguments: &[String]) -> Result<Box<dyn TaskSubject>, String> {
    match arguments {
        [] => Ok(Box::new(VirtualMachine)),
        [name] if name == "vm" => Ok(Box::new(VirtualMachine)),
        [name, pseudo] if name == "aot" => Ok(Box::new(NativeAdapter::launch(pseudo)?)),
        _ => Err("Subject must be `vm` or `aot <pseudo>`".to_owned()),
    }
}
