use crate::physical_error::{HostError, committed};
use crate::physical_network_resolver::{AddressResolver, SystemAddressResolver};
use crate::physical_network_tls::TlsConfiguration;
use serde::Deserialize;
use serde_json::Value;
use std::sync::Arc;
use std::sync::atomic::{AtomicBool, Ordering};
use tokio::time::timeout;

#[derive(Deserialize)]
#[serde(deny_unknown_fields)]
pub(super) struct NetworkRequest {
    pub(super) method: String,
    pub(super) url: String,
    pub(super) headers: Vec<(String, String)>,
    pub(super) body: Option<Vec<u8>>,
    pub(super) response_limit: Option<i64>,
    pub(super) timeout_nanos: Option<i64>,
    pub(super) effective_response_limit: Option<u64>,
    pub(super) effective_timeout_nanos: Option<u64>,
    pub(super) wire_limit: Option<u64>,
    pub(super) header_bytes_limit: Option<u64>,
    pub(super) headers_limit: Option<u64>,
}

pub(crate) fn perform(raw: &Value) -> Value {
    let Some(value) = raw.pointer("/arguments/0/value").cloned() else {
        return HostError::INVALID_PATH.reply();
    };
    let Ok(request) = serde_json::from_value::<NetworkRequest>(value) else {
        return HostError::INVALID_PATH.reply();
    };
    let Ok(runtime) = tokio::runtime::Builder::new_current_thread()
        .enable_all()
        .build()
    else {
        return HostError::INTERRUPTED.reply();
    };
    runtime.block_on(send_with_resolver(
        request,
        SystemAddressResolver,
        false,
        TlsConfiguration::from_host_roots(Vec::new()),
    ))
}

pub(super) async fn send_with_resolver<Resolver: AddressResolver + Send + 'static>(
    request: NetworkRequest,
    resolver: Resolver,
    local_test_origin: bool,
    tls_configuration: TlsConfiguration,
) -> Value {
    let sent = Arc::new(AtomicBool::new(false));
    let method = request.method.clone();
    let duration = match crate::physical_network_transport::request_timeout(&request) {
        Ok(duration) => duration,
        Err(error) => return error.reply(),
    };
    match timeout(
        duration,
        crate::physical_network_transport::send_once(
            request,
            resolver,
            crate::physical_network_transport::TransportOptions {
                local_test_origin,
                tls_configuration,
                sent: sent.clone(),
            },
        ),
    )
    .await
    {
        Ok(Ok(response)) => committed("http_response", response),
        Ok(Err(error)) => network_failure(error, &sent, &method),
        Err(_) => network_failure(HostError::TIMED_OUT, &sent, &method),
    }
}

fn network_failure(error: HostError, sent: &AtomicBool, method: &str) -> Value {
    HostError {
        code: error.code,
        uncertain: sent.load(Ordering::SeqCst) && may_mutate(method),
    }
    .reply()
}

fn may_mutate(method: &str) -> bool {
    matches!(method, "POST" | "PUT" | "PATCH" | "DELETE")
}
