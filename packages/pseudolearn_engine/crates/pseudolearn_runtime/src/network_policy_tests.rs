use crate::{HttpMethod, HttpRequestValue, HttpResponseValue};
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
