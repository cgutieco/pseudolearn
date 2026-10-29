use pseudolearn_runtime::{HostValue, HttpRequestValue, HttpResponseValue, MemoryError};

pub(crate) fn http_operation(
    receiver: Option<&HostValue>,
    identity: &str,
    arguments: &[HostValue],
) -> Result<Option<HostValue>, MemoryError> {
    let value = match identity {
        "http_request_new" => Some(request_new(arguments)?),
        "http_with_header" => Some(with_header(receiver, arguments)?),
        "http_with_body" => Some(with_body(receiver, arguments)?),
        "http_with_text_body" => Some(with_text_body(receiver, arguments)?),
        "http_with_response_limit" => Some(with_response_limit(receiver, arguments)?),
        "http_with_timeout" => Some(with_timeout(receiver, arguments)?),
        "http_status" => Some(status(receiver)?),
        "http_is_success" => Some(is_success(receiver)?),
        "http_header" => Some(header(receiver, arguments)?),
        "http_header_names" => Some(header_names(receiver)?),
        "http_body" => Some(body(receiver)?),
        "http_final_url" => Some(final_url(receiver)?),
        _ => None,
    };
    Ok(value)
}

fn request_new(arguments: &[HostValue]) -> Result<HostValue, MemoryError> {
    let [HostValue::HttpMethod(method), HostValue::Text(url)] = arguments else {
        return Err(MemoryError::Internal);
    };
    Ok(HostValue::HttpRequest(HttpRequestValue {
        method: *method,
        url: url.clone(),
        headers: Vec::new(),
        body: None,
        response_limit: None,
        timeout_nanos: None,
    }))
}

fn with_header(
    receiver: Option<&HostValue>,
    arguments: &[HostValue],
) -> Result<HostValue, MemoryError> {
    let mut request = request_receiver(receiver)?.clone();
    let [HostValue::Text(name), HostValue::Text(value)] = arguments else {
        return Err(MemoryError::Internal);
    };
    request.headers.push((name.clone(), value.clone()));
    Ok(HostValue::HttpRequest(request))
}

fn with_body(
    receiver: Option<&HostValue>,
    arguments: &[HostValue],
) -> Result<HostValue, MemoryError> {
    let mut request = request_receiver(receiver)?.clone();
    let [HostValue::Bytes(bytes)] = arguments else {
        return Err(MemoryError::Internal);
    };
    request.body = Some(bytes.clone());
    Ok(HostValue::HttpRequest(request))
}

fn with_text_body(
    receiver: Option<&HostValue>,
    arguments: &[HostValue],
) -> Result<HostValue, MemoryError> {
    let mut request = request_receiver(receiver)?.clone();
    let [HostValue::Text(text)] = arguments else {
        return Err(MemoryError::Internal);
    };
    request.body = Some(text.as_bytes().to_vec());
    Ok(HostValue::HttpRequest(request))
}

fn with_response_limit(
    receiver: Option<&HostValue>,
    arguments: &[HostValue],
) -> Result<HostValue, MemoryError> {
    let mut request = request_receiver(receiver)?.clone();
    let [HostValue::Integer(limit)] = arguments else {
        return Err(MemoryError::Internal);
    };
    request.response_limit = Some(*limit);
    Ok(HostValue::HttpRequest(request))
}

fn with_timeout(
    receiver: Option<&HostValue>,
    arguments: &[HostValue],
) -> Result<HostValue, MemoryError> {
    let mut request = request_receiver(receiver)?.clone();
    let [HostValue::Integer(timeout)] = arguments else {
        return Err(MemoryError::Internal);
    };
    request.timeout_nanos = Some(*timeout);
    Ok(HostValue::HttpRequest(request))
}

fn status(receiver: Option<&HostValue>) -> Result<HostValue, MemoryError> {
    let response = response_receiver(receiver)?;
    Ok(HostValue::Integer(i64::from(response.status)))
}

fn is_success(receiver: Option<&HostValue>) -> Result<HostValue, MemoryError> {
    let response = response_receiver(receiver)?;
    Ok(HostValue::Boolean((200..=299).contains(&response.status)))
}

fn header(receiver: Option<&HostValue>, arguments: &[HostValue]) -> Result<HostValue, MemoryError> {
    let response = response_receiver(receiver)?;
    let [HostValue::Text(name)] = arguments else {
        return Err(MemoryError::Internal);
    };
    let values = response
        .headers
        .iter()
        .filter(|(header, _)| header.eq_ignore_ascii_case(name))
        .map(|(_, value)| value.as_str())
        .collect::<Vec<_>>();
    Ok(HostValue::OptionalText(
        (!values.is_empty()).then(|| values.join(", ")),
    ))
}

fn header_names(receiver: Option<&HostValue>) -> Result<HostValue, MemoryError> {
    let response = response_receiver(receiver)?;
    let mut names = Vec::new();
    for (name, _) in &response.headers {
        let name = name.to_ascii_lowercase();
        if !names.contains(&name) {
            names.push(name);
        }
    }
    Ok(HostValue::TextList(names))
}

fn body(receiver: Option<&HostValue>) -> Result<HostValue, MemoryError> {
    Ok(HostValue::Bytes(response_receiver(receiver)?.body.clone()))
}

fn final_url(receiver: Option<&HostValue>) -> Result<HostValue, MemoryError> {
    Ok(HostValue::Text(
        response_receiver(receiver)?.final_url.clone(),
    ))
}

fn request_receiver(receiver: Option<&HostValue>) -> Result<&HttpRequestValue, MemoryError> {
    match receiver {
        Some(HostValue::HttpRequest(request)) => Ok(request),
        _ => Err(MemoryError::Internal),
    }
}

fn response_receiver(receiver: Option<&HostValue>) -> Result<&HttpResponseValue, MemoryError> {
    match receiver {
        Some(HostValue::HttpResponse(response)) => Ok(response),
        _ => Err(MemoryError::Internal),
    }
}
