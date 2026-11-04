use super::{Flow, Machine};
use crate::Fault;
use crate::evaluate::INVALID_BYTECODE;

impl Machine<'_> {
    pub(crate) fn extended_scalar(&mut self, site: u32) -> Result<Flow, Fault> {
        let site = *self
            .current
            .extended_scalars
            .get(usize::try_from(site).map_err(|_| INVALID_BYTECODE)?)
            .ok_or(INVALID_BYTECODE)?;
        let left = self.source_word(site.left)?;
        let right = site
            .right
            .map(|source| self.source_word(source))
            .transpose()?
            .unwrap_or(0);
        let result = site.evaluation.evaluate(left, right)?;
        self.set_scalar(site.destination, result)?;
        Ok(Flow::Continue)
    }
}
