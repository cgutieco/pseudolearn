use crate::{HttpMethod, HttpRequestValue, HttpResponseValue};
use pseudolearn_abi::IoErrorKind;

fn request(method: HttpMethod) -> HttpRequestValue {
    HttpRequestValue {
        method,
        url: "https://fake.test/start".to_owned(),
        headers: vec![
            ("Authorization".to_owned(), "secret".to_owned()),
            ("X-Api-Key".to_owned(), "api-secret".to_owned()),
            ("X-Request-Id".to_owned(), "request-id".to_owned()),
        ],
        body: (method == HttpMethod::Post).then(|| b"payload".to_vec()),
        response_limit: None,
        timeout_nanos: None,
        effective_response_limit: None,
        effective_timeout_nanos: None,
        wire_limit: None,
        header_bytes_limit: None,
        headers_limit: None,
    }
}

fn response(status: u16, final_url: &str, location: Option<&str>) -> HttpResponseValue {
    HttpResponseValue {
        status,
        headers: location
            .map(|value| vec![("Location".to_owned(), value.to_owned())])
            .unwrap_or_default(),
        body: Vec::new(),
        final_url: final_url.to_owned(),
    }
}

#[test]
fn resolves_relative_paths_against_final_url_and_drops_fragment() -> Result<(), String> {
    let original = request(HttpMethod::Get);
    let reply = response(302, "HTTPS://Fake.Test/a/start#old", Some("../done#new"));
    let redirected =
        crate::redirect_request(&original, &reply).map_err(|error| format!("{error:?}"))?;
    assert_eq!(redirected.url, "HTTPS://Fake.Test/done");
    Ok(())
}

#[test]
fn changes_post_to_get_for_301_302_and_303() -> Result<(), String> {
    for status in [301, 302, 303] {
        let original = request(HttpMethod::Post);
        let reply = response(status, "https://fake.test/start", Some("/next"));
        let redirected =
            crate::redirect_request(&original, &reply).map_err(|error| format!("{error:?}"))?;
        assert_eq!(redirected.method, HttpMethod::Get);
        assert_eq!(redirected.body, None);
    }
    Ok(())
}

#[test]
fn preserves_method_and_body_for_307_and_308() -> Result<(), String> {
    for status in [307, 308] {
        let original = request(HttpMethod::Post);
        let reply = response(status, "https://fake.test/start", Some("/next"));
        let redirected =
            crate::redirect_request(&original, &reply).map_err(|error| format!("{error:?}"))?;
        assert_eq!(redirected.method, HttpMethod::Post);
        assert_eq!(redirected.body, Some(b"payload".to_vec()));
    }
    Ok(())
}

#[test]
fn retains_credentials_only_for_the_same_origin() -> Result<(), String> {
    let original = request(HttpMethod::Get);
    let same_origin = response(301, "https://fake.test/start", Some("/next"));
    let retained =
        crate::redirect_request(&original, &same_origin).map_err(|error| format!("{error:?}"))?;
    assert_eq!(retained.headers, original.headers);
    let other_origin = response(
        301,
        "https://fake.test/start",
        Some("https://other.test/next"),
    );
    let removed =
        crate::redirect_request(&original, &other_origin).map_err(|error| format!("{error:?}"))?;
    assert_eq!(
        removed.headers,
        vec![("X-Request-Id".to_owned(), "request-id".to_owned())]
    );
    Ok(())
}

#[test]
fn rejects_unsupported_missing_duplicate_and_downgrade_redirects() {
    let original = request(HttpMethod::Get);
    let unsupported = response(304, "https://fake.test/start", Some("/next"));
    assert_eq!(
        crate::redirect_request(&original, &unsupported).map(|_| ()),
        Err(crate::IoError::from_kind(IoErrorKind::RedirectDenied))
    );
    let missing = response(302, "https://fake.test/start", None);
    assert_eq!(
        crate::redirect_request(&original, &missing).map(|_| ()),
        Err(crate::IoError::from_kind(IoErrorKind::RedirectDenied))
    );
    let mut duplicate = response(302, "https://fake.test/start", Some("/next"));
    duplicate
        .headers
        .push(("location".to_owned(), "/other".to_owned()));
    assert_eq!(
        crate::redirect_request(&original, &duplicate).map(|_| ()),
        Err(crate::IoError::from_kind(IoErrorKind::RedirectDenied))
    );
    let downgrade = response(
        302,
        "https://fake.test/start",
        Some("http://fake.test/next"),
    );
    assert_eq!(
        crate::redirect_request(&original, &downgrade).map(|_| ()),
        Err(crate::IoError::from_kind(IoErrorKind::RedirectDenied))
    );
}

#[test]
fn rejects_legacy_numeric_hosts_as_invalid_urls() {
    for hostname in ["2130706433", "0x7f000001", "0177.0.0.1"] {
        let url = format!("https://{hostname}/resource");
        assert_eq!(
            crate::network_url::parse_url(&url).map(|_| ()),
            Err(crate::IoError::from_kind(IoErrorKind::InvalidUrl)),
            "{hostname}"
        );
    }
    assert!(crate::network_url::parse_url("https://127.0.0.1/resource").is_ok());
}

#[test]
fn canonicalizes_ipv6_and_rejects_malformed_dns_labels() -> Result<(), String> {
    let parsed = crate::network_url::parse_url("https://[2001:0db8::1]/resource")
        .map_err(|error| format!("{error:?}"))?;
    assert_eq!(parsed.origin, "https://[2001:db8::1]:443");
    for url in ["https://fake..test/resource", "https://-fake.test/resource"] {
        assert_eq!(
            crate::network_url::parse_url(url).map(|_| ()),
            Err(crate::IoError::from_kind(IoErrorKind::InvalidUrl)),
            "{url}"
        );
    }
    Ok(())
}
