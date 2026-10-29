use crate::{
    Heap, HostValue, HttpMethod, HttpRequestValue, HttpResponseValue, MemoryOptions, new_bytes,
};

#[test]
fn encodes_and_decodes_immutable_request_values() -> Result<(), crate::MemoryError> {
    let request = HttpRequestValue {
        method: HttpMethod::Patch,
        url: "https://fake.test/a#part".to_owned(),
        headers: vec![("X-Test".to_owned(), "value".to_owned())],
        body: Some(vec![0, 255]),
        response_limit: Some(1024),
        timeout_nanos: Some(500),
    };
    let bytes = crate::http_values::request_bytes(&request)?;
    let mut heap = Heap::new(MemoryOptions::default());
    let handle = new_bytes(&mut heap, &bytes, &[])?;
    assert_eq!(crate::http_values::decode_request(&heap, handle)?, request);
    assert_eq!(
        crate::http_values::request_from_value(&HostValue::HttpRequest(request.clone())),
        Ok(&request)
    );
    Ok(())
}

#[test]
fn encodes_and_decodes_binary_responses() -> Result<(), crate::MemoryError> {
    let response = HttpResponseValue {
        status: 599,
        headers: vec![("X-Test".to_owned(), "value".to_owned())],
        body: vec![0, 255, 128],
        final_url: "https://fake.test/a".to_owned(),
    };
    let bytes = crate::http_values::response_bytes(&response)?;
    let mut heap = Heap::new(MemoryOptions::default());
    let handle = new_bytes(&mut heap, &bytes, &[])?;
    assert_eq!(
        crate::http_values::decode_response(&heap, handle)?,
        response
    );
    Ok(())
}

#[test]
fn rejects_mismatched_value_prefixes() -> Result<(), crate::MemoryError> {
    let response = HttpResponseValue {
        status: 200,
        headers: Vec::new(),
        body: Vec::new(),
        final_url: "https://fake.test/a".to_owned(),
    };
    let bytes = crate::http_values::response_bytes(&response)?;
    let mut heap = Heap::new(MemoryOptions::default());
    let handle = new_bytes(&mut heap, &bytes, &[])?;
    assert_eq!(
        crate::http_values::decode_request(&heap, handle),
        Err(crate::MemoryError::Internal)
    );
    Ok(())
}
