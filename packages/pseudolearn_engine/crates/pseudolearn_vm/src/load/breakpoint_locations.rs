use super::LoadedProgram;
use pseudolearn_bytecode::SourceSpan;

impl LoadedProgram {
    pub fn statement_location(
        &self,
        source: u32,
        line: u32,
        column: Option<u32>,
    ) -> Option<SourceSpan> {
        self.inner
            .functions
            .iter()
            .flat_map(|function| {
                function
                    .probed_statement_enters
                    .iter()
                    .filter_map(|position| function.probed_spans.get(*position).copied().flatten())
            })
            .filter(|span| {
                span.source_id.value() == source
                    && span.start_line == line
                    && column.is_none_or(|column| span.start_column == column)
            })
            .min_by_key(|span| span.start_column)
    }
}
