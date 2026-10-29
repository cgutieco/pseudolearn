use pseudolearn_api::ExecuteRequest;
use serde_json::json;

pub const BODY_SIZES: [usize; 4] = [0, 1024, 65_536, 1_048_576];
pub const JSON_SIZES: [usize; 3] = [1024, 65_536, 1_048_576];
pub const JSON_DEPTHS: [usize; 3] = [1, 16, 64];

pub struct Workload {
    pub name: String,
    pub category: String,
    pub request: ExecuteRequest,
    pub expected_output: String,
    pub body_bytes: usize,
    pub input_bytes: usize,
    pub json_nodes: usize,
}

pub fn all() -> Vec<Workload> {
    body_workloads()
        .into_iter()
        .chain(json_workloads())
        .collect()
}

fn body_workloads() -> Vec<Workload> {
    BODY_SIZES.iter().copied().map(body_workload).collect()
}

fn body_workload(size: usize) -> Workload {
    let address = format!("https://fake.test/body/{size}");
    let program = format!(
        "SubProceso Probe() Como Resultado<Entero, ErrorES>\nDefinir net Como RedCap <- Propagar SolicitarRed();\nDefinir response Como RespuestaHttp <- Propagar net.Enviar(PeticionHttp(MetodoHttp.GET, \"{address}\"));\nRetornar Exito(response.Cuerpo().Longitud());\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Escribir value;\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n"
    );
    let mut scripts = serde_json::Map::new();
    scripts.insert(
        format!("GET {address}"),
        json!({"estado": 200, "cuerpo_bytes": body(size)}),
    );
    let host = json!({
        "permissions": ["red"],
        "requested_permissions": ["red"],
        "http": scripts
    });
    Workload {
        name: format!("http-body-{size}"),
        category: "http_body".to_owned(),
        request: ExecuteRequest {
            program,
            host: Some(host),
            ..Default::default()
        },
        expected_output: format!("{size}\n"),
        body_bytes: size,
        input_bytes: 0,
        json_nodes: 0,
    }
}

fn body(size: usize) -> Vec<u8> {
    (0..size)
        .map(|position| u8::try_from(position % 251).unwrap_or(0))
        .collect()
}

fn json_workloads() -> Vec<Workload> {
    JSON_SIZES
        .iter()
        .flat_map(|size| JSON_DEPTHS.iter().map(move |depth| (*size, *depth)))
        .map(|(size, depth)| json_workload(size, depth))
        .collect()
}

fn json_workload(size: usize, depth: usize) -> Workload {
    let document = json_document(size, depth);
    let program = format!(
        "Algoritmo Main\nDefinir parsed Como Resultado<ValorJson, ErrorJson> <- AnalizarJson('{document}');\nSegun parsed Hacer\nExito(document): Escribir document.Tipo;\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n"
    );
    Workload {
        name: format!("json-{size}-depth-{depth}"),
        category: "json_parse".to_owned(),
        request: ExecuteRequest {
            program,
            ..Default::default()
        },
        expected_output: "Arreglo\n".to_owned(),
        body_bytes: 0,
        input_bytes: size,
        json_nodes: depth.saturating_add(1),
    }
}

fn json_document(size: usize, depth: usize) -> String {
    let fixed_bytes = depth.saturating_mul(2).saturating_add(2);
    let payload_bytes = size.saturating_sub(fixed_bytes);
    let mut document = String::with_capacity(size);
    document.push_str(&"[".repeat(depth));
    document.push('"');
    document.push_str(&"x".repeat(payload_bytes));
    document.push('"');
    document.push_str(&"]".repeat(depth));
    document
}

pub fn workload_names() -> Vec<String> {
    let mut names = BODY_SIZES
        .iter()
        .map(|size| format!("http-body-{size}"))
        .collect::<Vec<_>>();
    names.extend(JSON_SIZES.iter().flat_map(|size| {
        JSON_DEPTHS
            .iter()
            .map(move |depth| format!("json-{size}-depth-{depth}"))
    }));
    names
}
