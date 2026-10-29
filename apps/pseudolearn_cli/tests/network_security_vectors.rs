use std::io::{Read, Write};
use std::net::{Ipv4Addr, SocketAddr, TcpListener, TcpStream};
use std::process::{Command, Output};
use std::sync::mpsc::{self, Receiver, Sender};
use std::thread::{self, JoinHandle};
use std::time::{Duration, Instant};

struct LoopbackServer {
    address: SocketAddr,
    connected: Receiver<bool>,
    task: JoinHandle<()>,
}

fn server() -> Result<LoopbackServer, String> {
    let listener =
        TcpListener::bind((Ipv4Addr::LOCALHOST, 0)).map_err(|error| error.to_string())?;
    listener
        .set_nonblocking(true)
        .map_err(|error| error.to_string())?;
    let address = listener.local_addr().map_err(|error| error.to_string())?;
    let (sender, connected) = mpsc::channel();
    let task = thread::spawn(move || serve_once(listener, sender));
    Ok(LoopbackServer {
        address,
        connected,
        task,
    })
}

fn serve_once(listener: TcpListener, sender: Sender<bool>) {
    let deadline = Instant::now() + Duration::from_secs(4);
    while Instant::now() < deadline {
        match listener.accept() {
            Ok((mut stream, _)) => {
                let _ = read_request(&mut stream);
                let _ = stream.write_all(
                    b"HTTP/1.1 204 No Content\r\nContent-Length: 0\r\nConnection: close\r\n\r\n",
                );
                let _ = sender.send(true);
                return;
            }
            Err(error) if error.kind() == std::io::ErrorKind::WouldBlock => {
                thread::sleep(Duration::from_millis(2));
            }
            Err(_) => {
                let _ = sender.send(false);
                return;
            }
        }
    }
    let _ = sender.send(false);
}

fn read_request(stream: &mut TcpStream) -> std::io::Result<()> {
    let mut received = Vec::new();
    let mut buffer = [0; 1024];
    while !received.windows(4).any(|window| window == b"\r\n\r\n") {
        let count = stream.read(&mut buffer)?;
        if count == 0 {
            return Ok(());
        }
        received.extend_from_slice(&buffer[..count]);
    }
    Ok(())
}

fn source(url: &str, header: &str) -> String {
    format!(
        "SubProceso Probe() Como Resultado<Entero, ErrorES>\nDefinir net Como RedCap <- Propagar SolicitarRed();\nDefinir request Como PeticionHttp <- PeticionHttp(MetodoHttp.GET, \"{url}\"){header};\nDefinir response Como RespuestaHttp <- Propagar net.Enviar(request);\nRetornar Exito(response.Estado());\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Escribir value;\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n"
    )
}

fn run(server: &LoopbackServer, label: &str, header: &str) -> Result<Output, String> {
    let directory = std::env::temp_dir().join(format!(
        "pseudo-network-security-{}-{label}",
        std::process::id()
    ));
    std::fs::create_dir_all(&directory).map_err(|error| error.to_string())?;
    let program_path = directory.join("main.pseudo");
    let origin = format!("http://127.0.0.1:{}", server.address.port());
    let program = source(&format!("{origin}/texto"), header);
    std::fs::write(&program_path, program).map_err(|error| error.to_string())?;
    let output = Command::new(env!("CARGO_BIN_EXE_pseudo"))
        .arg("run")
        .arg(&program_path)
        .args(["--grant", "red", "--local-origin", &origin])
        .output()
        .map_err(|error| error.to_string())?;
    let _removed = std::fs::remove_dir_all(directory);
    Ok(output)
}

fn assert_rejected_without_connection(label: &str, header: &str) -> Result<(), String> {
    let server = server()?;
    let output = run(&server, label, header)?;
    if !output.status.success() {
        return Err(format!("CLI execution failed: {output:?}"));
    }
    let stdout = String::from_utf8_lossy(&output.stdout);
    if stdout != "peticion_invalida\n" {
        return Err(format!("unexpected result: {stdout:?}"));
    }
    if server
        .connected
        .recv_timeout(Duration::from_secs(5))
        .map_err(|error| error.to_string())?
    {
        return Err("invalid header reached the loopback transport".to_owned());
    }
    server
        .task
        .join()
        .map_err(|_| "loopback server failed".to_owned())
}

#[test]
fn crlf_request_headers_are_rejected_before_connecting() -> Result<(), String> {
    assert_rejected_without_connection(
        "crlf",
        ".ConCabecera(\"x-test\", \"safe\\r\\nX-Injected: true\")",
    )
}

#[test]
fn forbidden_request_headers_are_rejected_before_connecting() -> Result<(), String> {
    assert_rejected_without_connection("forbidden", ".ConCabecera(\"Host\", \"attacker.test\")")
}
