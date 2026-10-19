#![forbid(unsafe_code)]

use crate::error::CodegenError;
use cranelift_codegen::isa::{self, OwnedTargetIsa};
use cranelift_codegen::settings::{self, Configurable};
use target_lexicon::Triple;

#[derive(Clone, Copy, Debug, Default, Eq, PartialEq)]
pub enum ParameterRoots {
    AllLive,
    #[default]
    Borrowed,
}

#[derive(Clone, Debug)]
pub struct TargetConfig {
    triple: Triple,
    pub(crate) inspect: bool,
    verifier: bool,
    pub(crate) parameter_roots: ParameterRoots,
}

impl TargetConfig {
    pub fn host() -> Self {
        Self {
            triple: Triple::host(),
            inspect: false,
            parameter_roots: ParameterRoots::default(),
            verifier: cfg!(debug_assertions) || cfg!(test),
        }
    }

    pub fn for_triple(triple: Triple) -> Self {
        Self {
            triple,
            inspect: false,
            parameter_roots: ParameterRoots::default(),
            verifier: cfg!(debug_assertions) || cfg!(test),
        }
    }

    pub fn with_inspection(mut self) -> Self {
        self.inspect = true;
        self
    }

    pub fn with_verification(mut self) -> Self {
        self.verifier = true;
        self
    }

    pub fn with_parameter_roots(mut self, policy: ParameterRoots) -> Self {
        self.parameter_roots = policy;
        self
    }

    pub fn triple(&self) -> &Triple {
        &self.triple
    }

    pub(crate) fn build_isa(&self) -> Result<OwnedTargetIsa, CodegenError> {
        let mut flags = settings::builder();
        for (name, value) in [
            ("is_pic", "true"),
            ("opt_level", "speed"),
            ("preserve_frame_pointers", "true"),
        ] {
            flags
                .set(name, value)
                .map_err(|error| CodegenError::Target(error.to_string()))?;
        }
        flags
            .set(
                "enable_verifier",
                if self.verifier { "true" } else { "false" },
            )
            .map_err(|error| CodegenError::Target(error.to_string()))?;
        isa::lookup(self.triple.clone())
            .map_err(|error| CodegenError::Target(error.to_string()))?
            .finish(settings::Flags::new(flags))
            .map_err(|error| CodegenError::Target(error.to_string()))
    }
}
