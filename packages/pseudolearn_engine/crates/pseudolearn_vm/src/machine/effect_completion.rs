use super::Machine;
use crate::{Fault, evaluate::INVALID_BYTECODE, load::model::EffectSite};
use pseudolearn_runtime::{EffectOperation, HostReply};

impl Machine<'_> {
    pub(super) fn complete_local_view(
        &mut self,
        site: &EffectSite,
        word: u64,
    ) -> Result<(), Fault> {
        let [register] = site.result_cells.as_slice() else {
            return Err(INVALID_BYTECODE);
        };
        let cell = self.cell(*register)?;
        self.store_cell(cell, word)?;
        if let Some(destination) = site.destination {
            self.set_scalar(destination.index, 0)?;
        }
        Ok(())
    }

    fn echo_console_text(&mut self, site: &EffectSite) -> Result<(), Fault> {
        let register = site.arguments.first().ok_or(INVALID_BYTECODE)?;
        let text = pseudolearn_runtime::text_content(
            &self.heap,
            pseudolearn_runtime::Handle(self.reference(*register)?),
        )
        .map_err(super::memory::memory_fault)?
        .to_owned();
        self.emit_output(&text);
        self.output.push_str(&text);
        Ok(())
    }

    pub(super) fn complete_effect(
        &mut self,
        site: &EffectSite,
        operation: &EffectOperation,
        reply: &HostReply,
    ) -> Result<(), Fault> {
        let roots = self.memory_roots()?;
        let words = pseudolearn_runtime::host_reply_words(
            &mut self.heap,
            reply,
            (operation, site.result_class),
            &roots,
        )
        .map_err(super::memory::memory_fault)?;
        if words.len() != site.result_cells.len() {
            return Err(INVALID_BYTECODE);
        }
        let cells = site
            .result_cells
            .iter()
            .map(|register| self.cell(*register))
            .collect::<Result<Vec<_>, _>>()?;
        for (cell, word) in cells.into_iter().zip(words) {
            self.store_cell(cell, word)?;
        }
        let committed = matches!(reply, HostReply::Committed(_));
        if operation.identity == "console_write" && committed && !self.output_suppressed {
            self.echo_console_text(site)?;
        }
        if let Some(destination) = site.destination {
            self.set_scalar(destination.index, 0)?;
        }
        Ok(())
    }
}
