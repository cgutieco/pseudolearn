use crate::Resolution;
use crate::resolution::Collector;
use crate::spelling::{fragment_tokens, program_tokens};
use reference_model::{
    ExampleCheck, ExecutionReport, ExecutionRequest, Profile, ProgramBlock, ProgramSource,
    PublishedDiagnostic, RuleId, Token,
};

pub fn program_block(
    resolution: &Resolution<'_>,
    collector: &mut Collector<'_>,
    written: &ProgramSource,
) -> Option<ProgramBlock> {
    let source = effective_source(collector, written)?;
    let spanish = with_final_newline(&source.code);
    collector
        .programs
        .insert(source.id.clone(), spanish.clone());
    let code = target_code(resolution, &spanish);
    let lines = split_lines(program_tokens(resolution, &code));
    let mut block = ProgramBlock {
        id: source.id.clone(),
        title: source.title.clone(),
        source: code.clone(),
        lines,
        executed: source.execute,
        inputs: source.inputs.clone(),
        output: String::new(),
        termination: String::new(),
        diagnostics: Vec::new(),
    };
    if source.execute {
        let report = run(resolution, collector, &source, (&spanish, &code));
        block.output = report.output.clone();
        block.termination = report.termination.clone();
        block.diagnostics = published_diagnostics(&report, resolution.language);
    }
    Some(block)
}

fn effective_source(
    collector: &mut Collector<'_>,
    written: &ProgramSource,
) -> Option<ProgramSource> {
    if !written.code.trim().is_empty() {
        return Some(written.clone());
    }
    let Some(reused) = collector.reuse.programs.get(&written.id) else {
        collector.report(
            RuleId::Format,
            format!("program `{}` has no Spanish source to reuse", written.id),
        );
        return None;
    };
    let mut source = reused.clone();
    if !written.title.is_empty() {
        source.title = written.title.clone();
    }
    Some(source)
}

pub fn target_code(resolution: &Resolution<'_>, spanish: &str) -> String {
    if resolution.profile == Profile::Spanish {
        return spanish.to_owned();
    }
    let lexical = || -> String {
        fragment_tokens(resolution, spanish, Profile::Spanish)
            .into_iter()
            .map(|token| token.text)
            .collect()
    };
    if uses_alias(resolution, spanish) {
        return lexical();
    }
    resolution
        .engine
        .translate(spanish, resolution.profile)
        .unwrap_or_else(|_| lexical())
}

fn uses_alias(resolution: &Resolution<'_>, spanish: &str) -> bool {
    let characters: Vec<char> = spanish.chars().collect();
    resolution
        .engine
        .tokenize(spanish, Profile::Spanish)
        .iter()
        .any(|token| {
            let text: String = characters
                .get(token.start..token.end)
                .map(|part| part.iter().collect())
                .unwrap_or_default();
            resolution.aliases.contains(&text, Profile::Spanish)
        })
}

fn run(
    resolution: &Resolution<'_>,
    collector: &mut Collector<'_>,
    source: &ProgramSource,
    (spanish, code): (&str, &str),
) -> ExecutionReport {
    let request = |code: &str, profile: Profile| ExecutionRequest {
        code: code.to_owned(),
        profile,
        inputs: source.inputs.clone(),
        host: source.host.clone(),
        trace: false,
    };
    let source_report = resolution
        .engine
        .execute(&request(spanish, Profile::Spanish));
    let target_report = resolution
        .engine
        .execute(&request(code, resolution.profile));
    collector.examples.push(ExampleCheck {
        location: format!("{}#{}", collector.location, source.id),
        promise: source.promise.clone(),
        source_report,
        target_report: target_report.clone(),
    });
    target_report
}

pub fn published_diagnostics(
    report: &ExecutionReport,
    language: Profile,
) -> Vec<PublishedDiagnostic> {
    report
        .diagnostics
        .iter()
        .map(|diagnostic| PublishedDiagnostic {
            code: diagnostic.code.clone(),
            severity: diagnostic.severity.clone(),
            line: diagnostic.line,
            column: diagnostic.column,
            message: diagnostic.message(language).to_owned(),
        })
        .collect()
}

pub fn with_final_newline(code: &str) -> String {
    let trimmed = code.trim_end_matches('\n');
    format!("{trimmed}\n")
}

pub fn split_lines(tokens: Vec<Token>) -> Vec<Vec<Token>> {
    let mut lines = vec![Vec::new()];
    for token in tokens {
        let mut parts = token.text.split('\n').peekable();
        while let Some(part) = parts.next() {
            if !part.is_empty()
                && let Some(line) = lines.last_mut()
            {
                line.push(Token {
                    text: part.to_owned(),
                    category: token.category,
                });
            }
            if parts.peek().is_some() {
                lines.push(Vec::new());
            }
        }
    }
    if lines.last().is_some_and(Vec::is_empty) {
        lines.pop();
    }
    lines
}
