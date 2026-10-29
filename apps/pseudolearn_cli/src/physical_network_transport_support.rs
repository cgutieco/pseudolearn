use crate::physical_error::HostError;
use crate::physical_network_resolver::NetworkResolution;
use http::Uri;
use std::io;
use std::pin::Pin;
use std::sync::Arc;
use std::sync::atomic::{AtomicBool, Ordering};
use std::task::{Context, Poll};
use tokio::io::{AsyncRead, AsyncWrite, ReadBuf};

pub(super) struct TrackedIo<Stream> {
    pub(super) inner: Stream,
    pub(super) sent: Arc<AtomicBool>,
}

pub(super) fn limit(value: Option<u64>, default: u64) -> Result<usize, HostError> {
    match value {
        Some(value) => usize::try_from(value).map_err(|_| HostError::INVALID_PATH),
        None => usize::try_from(default).map_err(|_| HostError::INVALID_PATH),
    }
}

pub(super) fn request_uri(value: &str) -> Result<Uri, HostError> {
    let uri = value.parse::<Uri>().map_err(|_| HostError::INVALID_PATH)?;
    let scheme = uri.scheme_str().ok_or(HostError::INVALID_PATH)?;
    if !matches!(scheme, "http" | "https") || uri.authority().is_none() {
        return Err(HostError::INVALID_PATH);
    }
    if uri
        .authority()
        .is_some_and(|authority| authority.as_str().contains('@'))
    {
        return Err(HostError::INVALID_PATH);
    }
    Ok(uri)
}

pub(super) fn default_port(uri: &Uri) -> u16 {
    if uri.scheme_str() == Some("https") {
        443
    } else {
        80
    }
}

pub(super) fn resolution_error(error: &NetworkResolution) -> HostError {
    match error {
        NetworkResolution::InvalidHost => HostError::INVALID_PATH,
        NetworkResolution::DestinationDenied => HostError::PERMISSION_DENIED,
        NetworkResolution::ConnectionFailed | NetworkResolution::Addresses(_) => {
            HostError::INTERRUPTED
        }
    }
}

impl<Stream> AsyncRead for TrackedIo<Stream>
where
    Stream: AsyncRead + Unpin,
{
    fn poll_read(
        mut self: Pin<&mut Self>,
        context: &mut Context<'_>,
        buffer: &mut ReadBuf<'_>,
    ) -> Poll<io::Result<()>> {
        Pin::new(&mut self.inner).poll_read(context, buffer)
    }
}

impl<Stream> AsyncWrite for TrackedIo<Stream>
where
    Stream: AsyncWrite + Unpin,
{
    fn poll_write(
        mut self: Pin<&mut Self>,
        context: &mut Context<'_>,
        buffer: &[u8],
    ) -> Poll<io::Result<usize>> {
        let result = Pin::new(&mut self.inner).poll_write(context, buffer);
        if matches!(result, Poll::Ready(Ok(count)) if count > 0) {
            self.sent.store(true, Ordering::SeqCst);
        }
        result
    }

    fn poll_flush(mut self: Pin<&mut Self>, context: &mut Context<'_>) -> Poll<io::Result<()>> {
        Pin::new(&mut self.inner).poll_flush(context)
    }

    fn poll_shutdown(mut self: Pin<&mut Self>, context: &mut Context<'_>) -> Poll<io::Result<()>> {
        Pin::new(&mut self.inner).poll_shutdown(context)
    }
}
