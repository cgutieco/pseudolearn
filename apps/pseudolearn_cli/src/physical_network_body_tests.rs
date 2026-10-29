use crate::physical_error::HostError;
use crate::physical_network_body::{GzipBodyDecoder, is_gzip};
use flate2::Compression;
use flate2::write::GzEncoder;
use http::HeaderMap;
use std::io::Write;

fn gzip(value: &[u8]) -> Result<Vec<u8>, String> {
    let mut encoder = GzEncoder::new(Vec::new(), Compression::default());
    encoder
        .write_all(value)
        .map_err(|error| error.to_string())?;
    encoder.finish().map_err(|error| error.to_string())
}

#[test]
fn decodes_gzip_chunks_with_separate_wire_and_decoded_limits() -> Result<(), String> {
    let encoded = gzip(b"hello")?;
    let mut decoder = GzipBodyDecoder::new(encoded.len(), 5);
    for chunk in encoded.chunks(3) {
        decoder
            .write_chunk(chunk)
            .map_err(|error| error.code.to_owned())?;
    }
    assert_eq!(
        decoder.finish().map_err(|error| error.code.to_owned())?,
        b"hello"
    );
    Ok(())
}

#[test]
fn rejects_wire_overflow_decoded_overflow_and_invalid_gzip() -> Result<(), String> {
    let encoded = gzip(b"hello")?;
    let mut wire_decoder = GzipBodyDecoder::new(encoded.len().saturating_sub(1), 5);
    assert_eq!(
        wire_decoder.write_chunk(&encoded),
        Err(HostError::LIMIT_EXCEEDED)
    );
    let mut decoded_decoder = GzipBodyDecoder::new(encoded.len(), 4);
    decoded_decoder
        .write_chunk(&encoded)
        .map_err(|error| error.code.to_owned())?;
    assert_eq!(decoded_decoder.finish(), Err(HostError::LIMIT_EXCEEDED));
    let mut invalid_decoder = GzipBodyDecoder::new(32, 32);
    invalid_decoder
        .write_chunk(b"not gzip")
        .map_err(|error| error.code.to_owned())?;
    assert_eq!(invalid_decoder.finish(), Err(HostError::INVALID_RESPONSE));
    Ok(())
}

#[test]
fn recognizes_only_identity_and_gzip_content_encodings() -> Result<(), String> {
    let mut headers = HeaderMap::new();
    assert!(!is_gzip(&headers).map_err(|error| error.code.to_owned())?);
    headers.insert(
        http::header::CONTENT_ENCODING,
        "GZip".parse().map_err(|error| format!("{error}"))?,
    );
    assert!(is_gzip(&headers).map_err(|error| error.code.to_owned())?);
    headers.insert(
        http::header::CONTENT_ENCODING,
        "br".parse().map_err(|error| format!("{error}"))?,
    );
    assert_eq!(is_gzip(&headers), Err(HostError::INVALID_RESPONSE));
    Ok(())
}
