use crate::trap::Trap;
use pseudolearn_runtime::{
    EffectSession, ExecutionIdentity, MemoryHostProvider, ReplayError, console_record,
};
use std::collections::BTreeMap;

pub struct EffectChannel {
    pub(crate) session: EffectSession,
    pub(crate) provider: MemoryHostProvider,
    pub(crate) cancel_on_effect: Option<u64>,
    pub(crate) cancelled: bool,
    failure: Option<ReplayError>,
}

impl EffectChannel {
    pub fn new(session: EffectSession, provider: MemoryHostProvider) -> Self {
        Self {
            session,
            provider,
            cancel_on_effect: None,
            cancelled: false,
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
        let identity = ExecutionIdentity {
            strictness: "strict".to_owned(),
            limits: BTreeMap::new(),
            source_digest: String::new(),
            package_graph_digest: String::new(),
            profile: String::new(),
            seed: 0,
            statement_limit: None,
            permissions: Vec::new(),
        };
        Self::new(
            EffectSession::new(
                identity,
                pseudolearn_runtime::tape_privacy::DEFAULT_MAX_TAPE_BYTES,
            ),
            MemoryHostProvider::new(),
        )
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
