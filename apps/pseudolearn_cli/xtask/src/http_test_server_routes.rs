use flate2::Compression;
use flate2::write::GzEncoder;
use std::collections::HashMap;
use std::io::Write;
use std::net::SocketAddr;
use std::sync::Mutex;
use std::time::Duration;

const LARGE_RESPONSE_BYTES: usize = 8 * 1024 * 1024 + 1;
const COMPRESSED_RESPONSE_BYTES: usize = 8 * 1024 * 1024 + 1;

pub struct Request {
    pub method: String,
    pub target: String,
    pub headers: Vec<(String, String)>,
    pub body: Vec<u8>,
}

pub struct Response {
    pub status: u16,
    pub headers: Vec<(String, String)>,
    pub body: Vec<u8>,
    pub delay: Option<Duration>,
    pub close: bool,
    pub infinite: bool,
}

pub struct RouteContext {
    pub plain_address: SocketAddr,
    pub tls_address: SocketAddr,
    pub counters: Mutex<HashMap<String, u64>>,
}

impl RouteContext {
    pub fn new(plain_address: SocketAddr, tls_address: SocketAddr) -> Self {
        Self {
            plain_address,
            tls_address,
            counters: Mutex::new(HashMap::new()),
        }
    }
}

pub fn respond(request: Request, context: &RouteContext) -> Result<Response, String> {
    if request.method == "OPTIONS" {
        return Ok(response(204, Vec::new(), Vec::new()));
    }
    let path = request
        .target
        .split('?')
        .next()
        .ok_or("The request target is empty")?;
    match path {
        "/texto" => Ok(response(
            200,
            Vec::new(),
            b"Hello from PseudoLearn test server\n".to_vec(),
        )),
        "/binario" => Ok(response(200, Vec::new(), vec![0, 255, 13, 10])),
        "/vacio" => Ok(response(204, Vec::new(), Vec::new())),
        "/estado/404" => Ok(response(404, Vec::new(), b"Not found\n".to_vec())),
        "/estado/500" => Ok(response(500, Vec::new(), b"Server error\n".to_vec())),
        "/eco" => Ok(echo_response(request)),
        "/redireccion/mismo" => Ok(redirect_response("/texto")),
        "/redireccion/otro-origen" => Ok(redirect_response(&format!(
            "https://localhost:{}/texto",
            context.tls_address.port()
        ))),
        "/redireccion/http" => Ok(redirect_response(&format!(
            "http://127.0.0.1:{}/texto",
            context.plain_address.port()
        ))),
        "/grande" => Ok(response(200, Vec::new(), vec![b'x'; LARGE_RESPONSE_BYTES])),
        "/infinito" => Ok(infinite_response()),
        "/bomba-gzip" => compressed_response(),
        "/lento" => Ok(delayed_response()),
        "/cerrar-a-mitad" => Ok(close_response()),
        "/json-profundo" => Ok(response(200, Vec::new(), deep_json())),
        "/cabeceras-muchas" => Ok(many_headers_response()),
        "/contador" => counter_response(context),
        _ => Ok(response(404, Vec::new(), b"Unknown route\n".to_vec())),
    }
}

fn response(status: u16, headers: Vec<(String, String)>, body: Vec<u8>) -> Response {
    Response {
        status,
        headers,
        body,
        delay: None,
        close: false,
        infinite: false,
    }
}

fn echo_response(request: Request) -> Response {
    let echoed_headers = request
        .headers
        .iter()
        .map(|(name, value)| format!("{name}: {value}"))
        .collect::<Vec<_>>()
        .join("\n");
    let mut body = format!(
        "method={}\npath={}\nheaders:\n{}\nbody:\n",
        request.method, request.target, echoed_headers
    )
    .into_bytes();
    body.extend_from_slice(&request.body);
    let headers = vec![
        ("x-echo-method".to_owned(), request.method),
        ("x-echo-path".to_owned(), request.target),
    ];
    response(200, headers, body)
}

fn redirect_response(location: &str) -> Response {
    response(
        302,
        vec![("location".to_owned(), location.to_owned())],
        Vec::new(),
    )
}

fn infinite_response() -> Response {
    Response {
        status: 200,
        headers: Vec::new(),
        body: Vec::new(),
        delay: None,
        close: false,
        infinite: true,
    }
}

fn compressed_response() -> Result<Response, String> {
    let mut encoder = GzEncoder::new(Vec::new(), Compression::fast());
    encoder
        .write_all(&vec![b'x'; COMPRESSED_RESPONSE_BYTES])
        .map_err(|error| error.to_string())?;
    let body = encoder.finish().map_err(|error| error.to_string())?;
    Ok(response(
        200,
        vec![("content-encoding".to_owned(), "gzip".to_owned())],
        body,
    ))
}

fn delayed_response() -> Response {
    Response {
        status: 200,
        headers: Vec::new(),
        body: b"late\n".to_vec(),
        delay: Some(Duration::from_secs(60)),
        close: false,
        infinite: false,
    }
}

fn close_response() -> Response {
    Response {
        status: 0,
        headers: Vec::new(),
        body: Vec::new(),
        delay: None,
        close: true,
        infinite: false,
    }
}

fn deep_json() -> Vec<u8> {
    let mut document = "[".repeat(65);
    document.push('0');
    document.push_str(&"]".repeat(65));
    document.into_bytes()
}

fn many_headers_response() -> Response {
    let headers = (0..65)
        .map(|index| (format!("x-test-{index:02}"), "header".to_owned()))
        .collect();
    response(200, headers, b"headers\n".to_vec())
}

fn counter_response(context: &RouteContext) -> Result<Response, String> {
    let mut counters = context.counters.lock().map_err(|error| error.to_string())?;
    let count = counters.entry("/contador".to_owned()).or_default();
    *count = count.saturating_add(1);
    Ok(response(200, Vec::new(), count.to_string().into_bytes()))
}
