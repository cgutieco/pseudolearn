use pseudolearn_lexicon::Profile;
use pseudolearn_semantic::{SemanticOptions, analyze_with_options};
use pseudolearn_source::SourceText;
use pseudolearn_syntax::parse_source;
use pseudolearn_transpiler::{TargetLanguage, TranspileOutcome, TranspileRequest, transpile};

pub fn translate(program: &str, target: TargetLanguage) -> Result<TranspileOutcome, String> {
    let source = SourceText::new(program.to_owned());
    let (tree, _) = parse_source(&source, Profile::Spanish);
    let options = SemanticOptions {
        profile: Profile::Spanish,
    };
    let (module, _) = analyze_with_options(&tree, &source, options);
    let module = module.ok_or("analysis failed")?;
    let request = TranspileRequest {
        target,
        profile: Profile::Spanish,
        seed: Some(7),
        truth: "Verdadero",
        falsity: "Falso",
    };
    Ok(transpile(&module, &request))
}

pub fn code(program: &str, target: TargetLanguage) -> Result<String, String> {
    match translate(program, target)? {
        TranspileOutcome::Code(transpilation) => Ok(transpilation.code),
        TranspileOutcome::Unavailable(blockers) => Err(format!("unavailable: {blockers:?}")),
    }
}
