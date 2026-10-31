use crate::physical_error::{HostError, committed};
use crate::physical_network_resolver::{AddressResolver, SystemAddressResolver};
use crate::physical_network_tls::TlsConfiguration;
use serde::Deserialize;
use serde_json::Value;
use std::sync::Arc;
use std::sync::atomic::{AtomicBool, Ordering};
use tokio::time::timeout;

#[cfg(test)]
#[path = "physical_network_cancel_tests.rs"]
mod physical_network_cancel_tests;

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

pub(crate) fn perform_with_policy(
    raw: &Value,
    policy: &crate::physical_network::NetworkPolicy,
) -> Value {
    perform_controlled(raw, policy, None)
}

pub(crate) fn perform_cancellable(
    raw: &Value,
    policy: &crate::physical_network::NetworkPolicy,
    cancellation: Arc<AtomicBool>,
) -> Value {
    perform_controlled(raw, policy, Some(cancellation))
}

fn perform_controlled(
    raw: &Value,
    policy: &crate::physical_network::NetworkPolicy,
    cancellation: Option<Arc<AtomicBool>>,
) -> Value {
    let Some(value) = raw.pointer("/arguments/0/value").cloned() else {
        return HostError::INVALID_PATH.reply();
    };
    let Ok(request) = serde_json::from_value::<NetworkRequest>(value) else {
        return HostError::INVALID_PATH.reply();
    };
    let local_test_origin = match policy.local_test_origin(&request.url) {
        Ok(local_test_origin) => local_test_origin,
        Err(error) => return error.reply(),
    };
    let Ok(runtime) = tokio::runtime::Builder::new_current_thread()
        .enable_all()
        .build()
    else {
        return HostError::INTERRUPTED.reply();
    };
    runtime.block_on(send_controlled(
        request,
        SystemAddressResolver,
        local_test_origin,
        (policy.tls_configuration().clone(), cancellation),
    ))
}

#[cfg(test)]
pub(super) async fn send_with_resolver<Resolver: AddressResolver + Send + 'static>(
    request: NetworkRequest,
    resolver: Resolver,
    local_test_origin: bool,
    tls_configuration: TlsConfiguration,
) -> Value {
    send_controlled(
        request,
        resolver,
        local_test_origin,
        (tls_configuration, None),
    )
    .await
}

async fn send_controlled<Resolver: AddressResolver + Send + 'static>(
    request: NetworkRequest,
    resolver: Resolver,
    local_test_origin: bool,
    control: (TlsConfiguration, Option<Arc<AtomicBool>>),
) -> Value {
    let (tls_configuration, cancellation) = control;
    let sent = Arc::new(AtomicBool::new(false));
    let method = request.method.clone();
    let duration = match crate::physical_network_transport::request_timeout(&request) {
        Ok(duration) => duration,
        Err(error) => return error.reply(),
    };
    let request = timeout(
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
    );
    let outcome = await_cancellable(request, cancellation.as_deref()).await;
    match outcome {
        None => network_failure(HostError::INTERRUPTED, &sent, &method),
        Some(Ok(Ok(response))) => committed("http_response", response),
        Some(Ok(Err(error))) => network_failure(error, &sent, &method),
        Some(Err(_)) => network_failure(HostError::TIMED_OUT, &sent, &method),
    }
}

async fn await_cancellable<Outcome>(
    future: impl std::future::Future<Output = Outcome>,
    cancellation: Option<&AtomicBool>,
) -> Option<Outcome> {
    if cancellation.is_none() {
        return Some(future.await);
    }
    let mut future = std::pin::pin!(future);
    loop {
        if cancellation.is_some_and(|token| token.load(Ordering::SeqCst)) {
            return None;
        }
        if let Ok(outcome) = timeout(std::time::Duration::from_millis(5), future.as_mut()).await {
            return Some(outcome);
        }
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
