use crate::trap::Trap;
use pseudolearn_runtime::{EffectSession, ExecutionIdentity, ReplayError, console_record};

#[cfg(not(feature = "test-host"))]
pub type AotHostProvider = crate::physical_provider::PhysicalProvider;
#[cfg(feature = "test-host")]
pub type AotHostProvider = pseudolearn_runtime::ExecutionHostProvider;
use std::collections::BTreeMap;

pub struct EffectChannel {
    pub(crate) session: EffectSession,
    pub(crate) provider: AotHostProvider,
    pub(crate) cancel_on_effect: Option<u64>,
    pub(crate) cancelled: bool,
    pub(crate) delivery_order: Vec<u64>,
    pub(crate) pending_network: u64,
    pub(crate) merged_errors: bool,
    pub(crate) requested_exit: u8,
    failure: Option<ReplayError>,
}

impl EffectChannel {
    pub fn new(session: EffectSession, provider: AotHostProvider) -> Self {
        Self {
            session,
            provider,
            cancel_on_effect: None,
            cancelled: false,
            delivery_order: Vec::new(),
            pending_network: pseudolearn_runtime::NetworkLimits::default().pending,
            merged_errors: false,
            requested_exit: 0,
            failure: None,
        }
    }

    pub(crate) fn cancels_next_effect(&self) -> bool {
        let next_sequence = u64::try_from(self.session.tape().entries().len())
            .unwrap_or(u64::MAX)
            .saturating_add(1);
        self.cancel_on_effect == Some(next_sequence) && !self.session.is_replaying()
    }

    pub fn standalone() -> Self {
        Self::with_arguments(Vec::new())
    }

    pub(crate) fn with_arguments(arguments: Vec<String>) -> Self {
        let identity = ExecutionIdentity {
            limits: BTreeMap::new(),
            source_digest: String::new(),
            package_graph_digest: String::new(),
            profile: String::new(),
            seed: 0,
            statement_limit: None,
        };
        Self::new(
            EffectSession::new(
                identity,
                pseudolearn_runtime::tape_privacy::DEFAULT_MAX_TAPE_BYTES,
            ),
            program_host(arguments),
        )
    }

    pub(crate) fn requested_exit(&self) -> u8 {
        self.requested_exit
    }

    pub fn session(&self) -> &EffectSession {
        &self.session
    }

    pub fn host_observation(&self) -> (u64, usize) {
        (self.provider.calls, self.provider.live_resource_count())
    }

    pub fn failure(&self) -> Option<&ReplayError> {
        self.failure.as_ref()
    }

    pub fn finish(&mut self) {
        if let Err(error) = self.session.finish() {
            self.failure = Some(error);
        }
    }

    pub fn abort(&mut self) {
        self.session.abort();
    }

    pub(crate) fn reject(&mut self, error: ReplayError) -> Trap {
        self.failure = Some(error);
        Trap::named("internalFault")
    }

    pub(crate) fn replay_console(
        &mut self,
        operation: &str,
        arguments: Vec<u8>,
    ) -> Result<Option<Vec<u8>>, Trap> {
        if !self.session.is_replaying() {
            return Ok(None);
        }
        self.session
            .resolve(
                console_record(operation, arguments),
                Vec::new(),
                "committed",
            )
            .map(Some)
            .map_err(|error| self.reject(error))
    }

    pub(crate) fn record_console(
        &mut self,
        operation: &str,
        arguments: Vec<u8>,
        payload: Vec<u8>,
    ) -> Result<(), Trap> {
        let expected = self
            .session
            .resolve(
                console_record(operation, arguments),
                payload.clone(),
                "committed",
            )
            .map_err(|error| self.reject(error))?;
        if expected == payload {
            return Ok(());
        }
        Err(self.reject(ReplayError::Divergence))
    }
}

#[cfg(not(feature = "test-host"))]
pub(crate) fn program_host(arguments: Vec<String>) -> AotHostProvider {
    AotHostProvider::with_arguments(arguments)
}

#[cfg(feature = "test-host")]
pub(crate) fn program_host(_arguments: Vec<String>) -> AotHostProvider {
    AotHostProvider::new()
}
