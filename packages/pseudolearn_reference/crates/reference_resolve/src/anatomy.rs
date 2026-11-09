use crate::Resolution;
use crate::runs::runs;
use crate::spelling::fragment_tokens;
use reference_model::{AnatomyPart, AnatomySource, Block};

pub fn anatomy_block(resolution: &Resolution<'_>, parts: &[AnatomySource]) -> Block {
    Block::Anatomy {
        parts: parts
            .iter()
            .map(|part| AnatomyPart {
                tokens: fragment_tokens(resolution, &part.code, resolution.language),
                label: runs(resolution, &part.label),
            })
            .collect(),
    }
}
