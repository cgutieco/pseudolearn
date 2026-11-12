use std::io::{BufRead, BufReader, Read};
use std::process::{Child, Command, Stdio};

pub struct ServerProcess {
    child: Child,
    pub metadata: serde_json::Value,
}

impl Drop for ServerProcess {
    fn drop(&mut self) {
        let _ = self.child.kill();
        let _ = self.child.wait();
    }
}

pub fn start_server(certificate: &str) -> Result<ServerProcess, String> {
    let child = Command::new(env!("CARGO_BIN_EXE_xtask"))
        .args([
            "http-test-server",
            "--bind",
            "127.0.0.1",
            "--tls-certificate",
            certificate,
        ])
        .stdout(Stdio::piped())
        .stderr(Stdio::piped())
        .spawn()
        .map_err(|error| error.to_string())?;
    let mut server = ServerProcess {
        child,
        metadata: serde_json::Value::Null,
    };
    let output = server
        .child
        .stdout
        .take()
        .ok_or("The test server did not expose standard output")?;
    let mut reader = BufReader::new(output);
    let mut line = String::new();
    reader
        .read_line(&mut line)
        .map_err(|error| error.to_string())?;
    if line.is_empty() {
        let mut error_output = String::new();
        if let Some(mut output) = server.child.stderr.take() {
            output
                .read_to_string(&mut error_output)
                .map_err(|error| error.to_string())?;
        }
        return Err(format!(
            "The test server did not publish its addresses: {error_output}"
        ));
    }
    server.metadata = serde_json::from_str(&line).map_err(|error| error.to_string())?;
    Ok(server)
}

pub fn address(server: &ServerProcess, key: &str) -> Result<String, String> {
    server
        .metadata
        .get(key)
        .and_then(serde_json::Value::as_str)
        .map(str::to_owned)
        .ok_or_else(|| format!("Missing server address: {key}"))
}
