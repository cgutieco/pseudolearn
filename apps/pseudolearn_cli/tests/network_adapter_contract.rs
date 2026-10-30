use serde_json::Value;
use std::io::{BufRead, BufReader};
use std::process::{Child, Command, Output, Stdio};

struct TestServer {
    process: Child,
    http_address: String,
}

impl Drop for TestServer {
    fn drop(&mut self) {
        let _ = self.process.kill();
        let _ = self.process.wait();
    }
}

fn start_server() -> Result<TestServer, String> {
    let mut process = Command::new("cargo")
        .args(["xtask", "http-test-server", "--bind", "127.0.0.1"])
        .current_dir(env!("CARGO_MANIFEST_DIR"))
        .stdout(Stdio::piped())
        .stderr(Stdio::inherit())
        .spawn()
        .map_err(|error| error.to_string())?;
    let stdout = process
        .stdout
        .take()
        .ok_or_else(|| "HTTP server stdout is unavailable".to_owned())?;
    let mut reader = BufReader::new(stdout);
    let mut line = String::new();
    reader
        .read_line(&mut line)
        .map_err(|error| error.to_string())?;
    let report: Value = serde_json::from_str(&line).map_err(|error| error.to_string())?;
    let http_address = report
        .get("http_address")
        .and_then(Value::as_str)
        .ok_or_else(|| "HTTP server did not publish its address".to_owned())?
        .to_owned();
    Ok(TestServer {
        process,
        http_address,
    })
}

fn program(url: &str, authorization: bool, response_limit: Option<u64>) -> String {
    let header = if authorization {
        ".ConCabecera(\"Authorization\", \"Bearer local-test-secret\")"
    } else {
        ""
    };
    let limit =
        response_limit.map_or_else(String::new, |value| format!(".ConLimiteRespuesta({value})"));
    format!(
        "SubProceso Probe() Como Resultado<Entero, ErrorES>\nDefinir net Como RedCap <- Propagar SolicitarRed();\nDefinir request Como PeticionHttp <- PeticionHttp(MetodoHttp.GET, \"{url}\"){header}{limit};\nDefinir response Como RespuestaHttp <- Propagar net.Enviar(request);\nRetornar Exito(response.Estado() * 1000000 + response.Cuerpo().Longitud());\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Escribir value;\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n"
    )
}

fn execute(
    server: &TestServer,
    path: &str,
    authorization: bool,
    response_limit: Option<u64>,
) -> Result<Output, String> {
    let directory =
        std::env::temp_dir().join(format!("pseudo-network-contract-{}", std::process::id()));
    std::fs::create_dir_all(&directory).map_err(|error| error.to_string())?;
    let source_path = directory.join("main.pseudo");
    let url = format!("{}{path}", server.http_address);
    let source = program(&url, authorization, response_limit);
    std::fs::write(&source_path, source).map_err(|error| error.to_string())?;
    let output = Command::new(env!("CARGO_BIN_EXE_pseudo"))
        .arg("run")
        .arg(&source_path)
        .args(["--grant", "red", "--local-origin", &server.http_address])
        .output()
        .map_err(|error| error.to_string())?;
    let _removed = std::fs::remove_dir_all(directory);
    Ok(output)
}

#[test]
fn matches_statuses_bodies_and_redirects_from_the_local_contract_server() -> Result<(), String> {
    let server = start_server()?;
    for (path, status, length, authorization) in [
        ("/texto", 200_i64, 35_i64, false),
        ("/binario", 200, 4, false),
        ("/vacio", 204, 0, false),
        ("/estado/404", 404, 10, false),
        ("/estado/500", 500, 13, false),
        ("/redireccion/otro-origen", 302, 0, true),
        ("/redireccion/http", 302, 0, false),
    ] {
        let output = execute(&server, path, authorization, None)?;
        let expected = format!(
            "{}\n",
            status.saturating_mul(1_000_000).saturating_add(length)
        );
        if !output.status.success() || String::from_utf8_lossy(&output.stdout) != expected {
            return Err(format!("{path}: expected {expected:?}, got {output:?}"));
        }
    }
    for path in ["/grande", "/infinito", "/bomba-gzip"] {
        let output = execute(&server, path, false, Some(64))?;
        if !output.status.success()
            || String::from_utf8_lossy(&output.stdout) != "limite_excedido\n"
        {
            return Err(format!(
                "{path}: response limit was not enforced: {output:?}"
            ));
        }
    }
    Ok(())
}

fn failure_program(method: &str, url: &str, modifiers: &str) -> String {
    format!(
        "SubProceso Probe() Como Resultado<Entero, ErrorES>\nDefinir net Como RedCap <- Propagar SolicitarRed();\nDefinir request Como PeticionHttp <- PeticionHttp(MetodoHttp.{method}, \"{url}\"){modifiers};\nSegun net.Enviar(request) Hacer\nExito(response): Escribir response.Estado();\nError(problem): Escribir problem.Codigo, \":\", problem.Incierto;\nFinSegun\nRetornar Exito(0);\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value):\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n"
    )
}

fn execute_failure(server: &TestServer, label: &str, source: &str) -> Result<String, String> {
    let directory = std::env::temp_dir().join(format!(
        "pseudo-network-failure-{}-{label}",
        std::process::id()
    ));
    std::fs::create_dir_all(&directory).map_err(|error| error.to_string())?;
    let source_path = directory.join("main.pseudo");
    std::fs::write(&source_path, source).map_err(|error| error.to_string())?;
    let output = Command::new(env!("CARGO_BIN_EXE_pseudo"))
        .arg("run")
        .arg(&source_path)
        .args(["--grant", "red", "--local-origin", &server.http_address])
        .output()
        .map_err(|error| error.to_string())?;
    let _removed = std::fs::remove_dir_all(directory);
    Ok(String::from_utf8_lossy(&output.stdout).into_owned())
}

#[test]
fn marks_cut_mutating_requests_uncertain_and_cut_reads_certain() -> Result<(), String> {
    let server = start_server()?;
    let cut = format!("{}/cerrar-a-mitad", server.http_address);
    let slow = format!("{}/lento", server.http_address);
    for (label, method, url, modifiers, expected) in [
        (
            "post",
            "POST",
            &cut,
            ".ConCuerpoTexto(\"x\")",
            "interrumpido:Verdadero\n",
        ),
        ("delete", "DELETE", &cut, "", "interrumpido:Verdadero\n"),
        ("get", "GET", &cut, "", "interrumpido:Falso\n"),
        (
            "slow",
            "GET",
            &slow,
            ".ConTiempoMaximo(300000000)",
            "tiempo_agotado:Falso\n",
        ),
    ] {
        let source = failure_program(method, url, modifiers);
        let actual = execute_failure(&server, label, &source)?;
        if actual != expected {
            return Err(format!("{label}: expected {expected:?}, got {actual:?}"));
        }
    }
    Ok(())
}
