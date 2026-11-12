#![forbid(unsafe_code)]

mod physical_console;
mod physical_directory_ops;
mod physical_download;
mod physical_environment;
mod physical_error;
mod physical_file_append;
mod physical_files;
mod physical_host;
mod physical_local_zone;
mod physical_network;
mod physical_network_address;
mod physical_network_body;
mod physical_network_resolver;
pub mod physical_network_send;
mod physical_network_tls;
mod physical_network_transport;
mod physical_network_transport_support;
mod physical_request;

pub use physical_download::{DownloadError, DownloadRequest, download_to_file};
pub use physical_error::HostError;
pub use physical_host::{PhysicalHost, entropy_seed};
pub use physical_network::NetworkPolicy;
pub use physical_network_tls::TlsConfiguration;
mod physical_paths;
mod worker;
pub use worker::HostWorker;

#[cfg(test)]
mod physical_console_tests;
#[cfg(test)]
mod physical_download_tests;
#[cfg(test)]
mod physical_environment_tests;

#[cfg(test)]
mod physical_local_zone_tests;

#[cfg(test)]
mod physical_network_body_tests;

#[cfg(test)]
mod physical_network_stream_tests;

#[cfg(test)]
mod physical_network_tls_send_tests;

#[cfg(test)]
mod physical_network_send_tests;
