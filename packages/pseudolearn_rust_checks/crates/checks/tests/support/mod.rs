use pseudolearn_check_source::loading::SourceFile;
use std::path::PathBuf;

pub fn source(text: &str) -> Result<SourceFile, Box<dyn std::error::Error>> {
    Ok(SourceFile {
        path: PathBuf::from("execution.rs"),
        relative: "src/execution.rs".to_owned(),
        text: text.to_owned(),
        syntax: syn::parse_file(text)?,
        layer: 0,
        is_test: false,
    })
}

pub fn rules() -> Result<pseudolearn_check_model::Architecture, String> {
    pseudolearn_check_source::loading::read_architecture(
        &PathBuf::from(env!("CARGO_MANIFEST_DIR")).join("../.."),
    )
}
