use crate::{
    HostEffectRequest, HostReply, HostValue, HttpMethod, HttpRequestValue, HttpResponseValue,
    IoError,
};
use pseudolearn_abi::IoErrorKind;
use std::collections::BTreeSet;

fn request(url: &str, method: HttpMethod) -> HttpRequestValue {
    HttpRequestValue {
        method,
        url: url.to_owned(),
        headers: Vec::new(),
        body: None,
        response_limit: None,
        timeout_nanos: None,
        effective_response_limit: None,
        effective_timeout_nanos: None,
        wire_limit: None,
        header_bytes_limit: None,
        headers_limit: None,
    }
}

#[test]
fn accepts_granted_http_and_https_origins_without_fragments() -> Result<(), String> {
    let origins = BTreeSet::from([
        "https://fake.test:443".to_owned(),
        "http://localhost:80".to_owned(),
    ]);
    let secure = crate::network_policy::validate_request(
        &request("HTTPS://Fake.Test/a#section", HttpMethod::Get),
        &origins,
    )
    .map_err(|error| format!("{error:?}"))?;
    let local = crate::network_policy::validate_request(
        &request("http://localhost/a", HttpMethod::Get),
        &origins,
    )
    .map_err(|error| format!("{error:?}"))?;
    assert_eq!(secure.origin, "https://fake.test:443");
    assert_eq!(secure.without_fragment, "HTTPS://Fake.Test/a");
    assert_eq!(local.origin, "http://localhost:80");
    Ok(())
}

#[test]
fn unrestricted_network_accepts_any_http_destination() {
    for url in [
        "http://127.0.0.1/a",
        "http://192.168.1.2/a",
        "http://example.test/a",
        "https://other.test/a",
    ] {
        assert!(
            crate::network_policy::validate_request(
                &request(url, HttpMethod::Get),
                &BTreeSet::new()
            )
            .is_ok()
        );
    }
}

#[test]
fn unrestricted_network_accepts_loopback_ports_and_transport_unrelated_headers() {
    let mut cookie_request = request("http://localhost:8080/a", HttpMethod::Post);
    cookie_request.headers = vec![
        ("Cookie".to_owned(), "session=1".to_owned()),
        ("Authorization".to_owned(), "Bearer token".to_owned()),
    ];
    cookie_request.body = Some(vec![1]);
    let parsed = crate::network_policy::validate_request(&cookie_request, &BTreeSet::new());
    assert_eq!(
        parsed.map(|parsed| parsed.origin),
        Ok("http://localhost:8080".to_owned())
    );
}

#[test]
fn a_voluntary_attenuation_is_the_only_source_of_destination_denial() {
    let attenuated = BTreeSet::from(["http://127.0.0.1:9000".to_owned()]);
    assert!(
        crate::network_policy::validate_request(
            &request("http://127.0.0.1:9000/a", HttpMethod::Get),
            &attenuated,
        )
        .is_ok()
    );
    assert_eq!(
        crate::network_policy::validate_request(
            &request("http://127.0.0.1:9001/a", HttpMethod::Get),
            &attenuated,
        )
        .map(|_| ()),
        Err(crate::IoError::from_kind(IoErrorKind::DestinationDenied))
    );
    assert!(
        crate::network_policy::validate_request(
            &request("http://127.0.0.1:9001/a", HttpMethod::Get),
            &BTreeSet::new(),
        )
        .is_ok()
    );
}

#[test]
fn rejects_invalid_urls_and_ungranted_origins() {
    let origins = BTreeSet::from(["https://fake.test:443".to_owned()]);
    for url in [
        "fake.test/a",
        "ftp://fake.test/a",
        "https:///a",
        "https://user@fake.test/a",
        "https://fáké.test/a",
        "https://fake.test/a b",
    ] {
        assert_eq!(
            crate::network_policy::validate_request(&request(url, HttpMethod::Get), &origins)
                .map(|_| ()),
            Err(crate::IoError::from_kind(IoErrorKind::InvalidUrl)),
            "{url}"
        );
    }
    assert_eq!(
        crate::network_policy::validate_request(
            &request("https://other.test/a", HttpMethod::Get),
            &origins,
        )
        .map(|_| ()),
        Err(crate::IoError::from_kind(IoErrorKind::DestinationDenied))
    );
}

#[test]
fn rejects_prohibited_headers_and_bodies_on_read_methods() {
    let origins = BTreeSet::from(["https://fake.test:443".to_owned()]);
    let mut header_request = request("https://fake.test/a", HttpMethod::Get);
    header_request.headers = vec![("Host".to_owned(), "fake.test".to_owned())];
    assert_eq!(
        crate::network_policy::validate_request(&header_request, &origins),
        Err(crate::IoError::from_kind(IoErrorKind::InvalidRequest))
    );
    header_request.headers = vec![("X-Test".to_owned(), "first\nsecond".to_owned())];
    assert_eq!(
        crate::network_policy::validate_request(&header_request, &origins),
        Err(crate::IoError::from_kind(IoErrorKind::InvalidRequest))
    );
    let mut body_request = request("https://fake.test/a", HttpMethod::Head);
    body_request.body = Some(Vec::new());
    assert_eq!(
        crate::network_policy::validate_request(&body_request, &origins),
        Err(crate::IoError::from_kind(IoErrorKind::InvalidRequest))
    );
}

#[test]
fn treats_http_error_statuses_as_responses() {
    for status in [100, 200, 404, 500, 599] {
        let response = HttpResponseValue {
            status,
            headers: Vec::new(),
            body: Vec::new(),
            final_url: "https://fake.test/a".to_owned(),
        };
        assert_eq!(crate::network_policy::validate_response(&response), Ok(()));
    }
    let response = HttpResponseValue {
        status: 101,
        headers: Vec::new(),
        body: Vec::new(),
        final_url: "https://fake.test/a".to_owned(),
    };
    assert_eq!(
        crate::network_policy::validate_response(&response),
        Err(crate::IoError::from_kind(IoErrorKind::InvalidResponse))
    );
}

#[test]
fn classifies_uncertain_network_replies_by_method() -> Result<(), String> {
    let operation = crate::effect_operation("network_send").ok_or("missing network_send")?;
    for method in HttpMethod::ALL {
        let request = HostEffectRequest {
            effect_seq: 1,
            operation: "network_send".to_owned(),
            receiver: None,
            arguments: vec![HostValue::HttpRequest(request(
                "https://fake.test/a",
                method,
            ))],
            result_capability: None,
            source_node_id: 0,
        };
        let uncertain = HostReply::failure(IoError::new(IoErrorKind::Interrupted, true));
        let failed = HostReply::failure(IoError::from_kind(IoErrorKind::Interrupted));
        let may_mutate = !matches!(method, HttpMethod::Get | HttpMethod::Head);
        assert_eq!(
            crate::host_validation::reply(operation, &request, &uncertain).is_ok(),
            may_mutate,
            "{}",
            method.as_str()
        );
        assert!(crate::host_validation::reply(operation, &request, &failed).is_ok());
    }
    Ok(())
}
