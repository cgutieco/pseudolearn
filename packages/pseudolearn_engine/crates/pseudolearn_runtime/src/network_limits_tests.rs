use crate::{
    HttpMethod, HttpRequestValue, HttpResponseValue, IoError, NetworkLimits, pending_limit_exceeded,
};
use pseudolearn_abi::IoErrorKind;

fn request() -> HttpRequestValue {
    HttpRequestValue {
        method: HttpMethod::Get,
        url: "https://fake.test/resource".to_owned(),
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

fn response(body: &[u8], headers: Vec<(String, String)>) -> HttpResponseValue {
    HttpResponseValue {
        status: 200,
        headers,
        body: body.to_vec(),
        final_url: "https://fake.test/resource".to_owned(),
    }
}

#[test]
fn accepts_a_body_at_the_effective_limit_and_rejects_one_byte_more() {
    let limits = NetworkLimits {
        body_bytes: 4,
        ..NetworkLimits::default()
    };
    let mut request = request();
    request.response_limit = Some(4);
    assert!(crate::network_limits::prepare_request(&mut request, limits).is_ok());
    assert_eq!(
        crate::network_limits::validate_response(&response(b"1234", Vec::new()), &request),
        Ok(())
    );
    assert_eq!(
        crate::network_limits::validate_response(&response(b"12345", Vec::new()), &request),
        Err(IoError::from_kind(IoErrorKind::LimitExceeded))
    );
}

#[test]
fn clamps_response_and_timeout_requests_to_host_limits() {
    let limits = NetworkLimits {
        body_bytes: 4,
        timeout_nanos: 30,
        ..NetworkLimits::default()
    };
    let mut request = request();
    request.response_limit = Some(8);
    request.timeout_nanos = Some(40);
    assert!(crate::network_limits::prepare_request(&mut request, limits).is_ok());
    assert_eq!(request.effective_response_limit, Some(4));
    assert_eq!(request.effective_timeout_nanos, Some(30));
}

#[test]
fn rejects_nonpositive_request_limits() {
    let mut response_request = request();
    response_request.response_limit = Some(0);
    assert_eq!(
        crate::network_limits::prepare_request(&mut response_request, NetworkLimits::default()),
        Err(IoError::from_kind(IoErrorKind::InvalidRequest))
    );
    let mut timeout_request = request();
    timeout_request.timeout_nanos = Some(-1);
    assert_eq!(
        crate::network_limits::prepare_request(&mut timeout_request, NetworkLimits::default()),
        Err(IoError::from_kind(IoErrorKind::InvalidRequest))
    );
}

#[test]
fn rejects_too_many_response_headers() {
    let limits = NetworkLimits {
        headers: 1,
        ..NetworkLimits::default()
    };
    let mut request = request();
    assert!(crate::network_limits::prepare_request(&mut request, limits).is_ok());
    assert_eq!(
        crate::network_limits::validate_response(
            &response(
                b"",
                vec![
                    ("x-one".to_owned(), "1".to_owned()),
                    ("x-two".to_owned(), "2".to_owned()),
                ],
            ),
            &request,
        ),
        Err(IoError::from_kind(IoErrorKind::LimitExceeded))
    );
}

#[test]
fn counts_header_names_values_and_wire_delimiters() {
    let limits = NetworkLimits {
        header_bytes: 5,
        ..NetworkLimits::default()
    };
    let mut request = request();
    assert!(crate::network_limits::prepare_request(&mut request, limits).is_ok());
    assert_eq!(
        crate::network_limits::validate_response(
            &response(b"", vec![("x".to_owned(), "v".to_owned())]),
            &request,
        ),
        Err(IoError::from_kind(IoErrorKind::LimitExceeded))
    );
}

#[test]
fn accepts_headers_at_the_count_and_byte_limits() {
    let limits = NetworkLimits {
        header_bytes: 5,
        headers: 1,
        ..NetworkLimits::default()
    };
    let mut request = request();
    assert!(crate::network_limits::prepare_request(&mut request, limits).is_ok());
    assert_eq!(
        crate::network_limits::validate_response(
            &response(b"", vec![("x".to_owned(), "".to_owned())]),
            &request,
        ),
        Ok(())
    );
}

#[test]
fn accepts_request_body_at_wire_limit_and_rejects_one_byte_more() {
    let limits = NetworkLimits {
        wire_bytes: 2,
        ..NetworkLimits::default()
    };
    let mut accepted = request();
    accepted.body = Some(b"ab".to_vec());
    assert_eq!(
        crate::network_limits::prepare_request(&mut accepted, limits),
        Ok(())
    );
    let mut rejected = request();
    rejected.body = Some(b"abc".to_vec());
    assert_eq!(
        crate::network_limits::prepare_request(&mut rejected, limits),
        Err(IoError::from_kind(IoErrorKind::LimitExceeded))
    );
}

#[test]
fn permits_the_pending_limit_and_rejects_the_next_request() {
    assert!(!pending_limit_exceeded(4, 4));
    assert!(pending_limit_exceeded(5, 4));
}
