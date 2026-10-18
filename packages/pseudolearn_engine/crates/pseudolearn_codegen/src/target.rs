#![forbid(unsafe_code)]

use crate::error::CodegenError;
use cranelift_codegen::isa::{self, OwnedTargetIsa};
use cranelift_codegen::settings::{self, Configurable};
use target_lexicon::Triple;

#[derive(Clone, Debug)]
pub struct TargetConfig {
    triple: Triple,
}

impl TargetConfig {
    pub fn host() -> Self {
        Self {
            triple: Triple::host(),
        }
    }

    pub fn for_triple(triple: Triple) -> Self {
        Self { triple }
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
        isa::lookup(self.triple.clone())
            .map_err(|error| CodegenError::Target(error.to_string()))?
            .finish(settings::Flags::new(flags))
            .map_err(|error| CodegenError::Target(error.to_string()))
    }
}
