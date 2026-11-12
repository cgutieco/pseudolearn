use crate::physical_error::HostError;
use flate2::write::MultiGzDecoder;
use http::header::CONTENT_ENCODING;
use http_body_util::BodyExt;
use std::io::{self, Write};

pub(crate) fn is_gzip(headers: &http::HeaderMap) -> Result<bool, HostError> {
    let Some(value) = headers.get(CONTENT_ENCODING) else {
        return Ok(false);
    };
    let encoding = value.to_str().map_err(|_| HostError::INVALID_RESPONSE)?;
    match encoding.trim().to_ascii_lowercase().as_str() {
        "identity" => Ok(false),
        "gzip" => Ok(true),
        _ => Err(HostError::INVALID_RESPONSE),
    }
}

pub(crate) async fn collect(
    mut stream: hyper::body::Incoming,
    wire_limit: usize,
    decoded_limit: usize,
    compressed: bool,
) -> Result<Vec<u8>, HostError> {
    if compressed {
        collect_gzip(&mut stream, wire_limit, decoded_limit).await
    } else {
        collect_identity(&mut stream, wire_limit, decoded_limit).await
    }
}

async fn collect_identity(
    stream: &mut hyper::body::Incoming,
    wire_limit: usize,
    decoded_limit: usize,
) -> Result<Vec<u8>, HostError> {
    let mut body = Vec::new();
    while let Some(frame) = stream.frame().await {
        let frame = frame.map_err(|_| HostError::INVALID_RESPONSE)?;
        if let Ok(chunk) = frame.into_data() {
            if body.len().saturating_add(chunk.len()) > wire_limit
                || body.len().saturating_add(chunk.len()) > decoded_limit
            {
                return Err(HostError::LIMIT_EXCEEDED);
            }
            body.extend_from_slice(&chunk);
        }
    }
    Ok(body)
}

async fn collect_gzip(
    stream: &mut hyper::body::Incoming,
    wire_limit: usize,
    decoded_limit: usize,
) -> Result<Vec<u8>, HostError> {
    let mut decoder = GzipBodyDecoder::new(wire_limit, decoded_limit);
    while let Some(frame) = stream.frame().await {
        let frame = frame.map_err(|_| HostError::INVALID_RESPONSE)?;
        if let Ok(chunk) = frame.into_data() {
            decoder.write_chunk(&chunk)?;
        }
    }
    decoder.finish()
}

pub(crate) struct GzipBodyDecoder {
    decoder: MultiGzDecoder<LimitedBody>,
    wire_bytes: usize,
    wire_limit: usize,
}

impl GzipBodyDecoder {
    pub(crate) fn new(wire_limit: usize, decoded_limit: usize) -> Self {
        Self {
            decoder: MultiGzDecoder::new(LimitedBody {
                bytes: Vec::new(),
                limit: decoded_limit,
            }),
            wire_bytes: 0,
            wire_limit,
        }
    }

    pub(crate) fn write_chunk(&mut self, chunk: &[u8]) -> Result<(), HostError> {
        self.wire_bytes = self.wire_bytes.saturating_add(chunk.len());
        if self.wire_bytes > self.wire_limit {
            return Err(HostError::LIMIT_EXCEEDED);
        }
        self.decoder
            .write_all(chunk)
            .map_err(|error| decode_error(&error))
    }

    pub(crate) fn finish(self) -> Result<Vec<u8>, HostError> {
        self.decoder
            .finish()
            .map(|body| body.bytes)
            .map_err(|error| decode_error(&error))
    }
}

fn decode_error(error: &io::Error) -> HostError {
    if error.kind() == io::ErrorKind::FileTooLarge {
        HostError::LIMIT_EXCEEDED
    } else {
        HostError::INVALID_RESPONSE
    }
}

struct LimitedBody {
    bytes: Vec<u8>,
    limit: usize,
}

impl Write for LimitedBody {
    fn write(&mut self, input: &[u8]) -> io::Result<usize> {
        if input.len() > self.limit.saturating_sub(self.bytes.len()) {
            return Err(io::Error::new(
                io::ErrorKind::FileTooLarge,
                "decoded response limit exceeded",
            ));
        }
        self.bytes
            .try_reserve(input.len())
            .map_err(io::Error::other)?;
        self.bytes.extend_from_slice(input);
        Ok(input.len())
    }

    fn flush(&mut self) -> io::Result<()> {
        Ok(())
    }
}
