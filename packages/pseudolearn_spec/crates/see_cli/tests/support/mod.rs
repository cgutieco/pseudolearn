use std::path::PathBuf;
use std::process::{Command, Output};

pub struct Fixture {
    pub root: PathBuf,
}

impl Fixture {
    pub fn create() -> Result<Self, String> {
        static NEXT: std::sync::atomic::AtomicUsize = std::sync::atomic::AtomicUsize::new(0);
        let sequence = NEXT.fetch_add(1, std::sync::atomic::Ordering::Relaxed);
        let root = std::env::temp_dir().join(format!("see-cli-{}-{sequence}", std::process::id()));
        std::fs::create_dir_all(root.join("specifications/see"))
            .map_err(|error| error.to_string())?;
        std::fs::create_dir_all(root.join("subjects/reference"))
            .map_err(|error| error.to_string())?;
        let sample = include_str!("../../../../fixtures/valid/specifications/sample.md")
            .replace(
                "\"id\": \"LANG.TEST.SAMPLE\"",
                "\"id\": \"SEE.TEST.SAMPLE\"",
            )
            .replace("\"dominio\": \"lenguaje\"", "\"dominio\": \"proceso\"")
            .replace("\"engine\",\n    \"aot\"", "\"reference\"");
        std::fs::write(root.join("specifications/see/sample.md"), sample)
            .map_err(|error| error.to_string())?;
        std::fs::write(
            root.join("subjects/reference/conformance.yaml"),
            r#"{"sujeto":"reference","estado":"retirado","paquete":"historical","activadas":[],"fases_cerradas":[],"vinculos":[]}"#,
        )
        .map_err(|error| error.to_string())?;
        Ok(Self { root })
    }

    pub fn execute(&self, arguments: &[&str]) -> Result<Output, String> {
        Command::new(env!("CARGO_BIN_EXE_see"))
            .args(arguments)
            .arg("--root")
            .arg(&self.root)
            .output()
            .map_err(|error| error.to_string())
    }
}

impl Drop for Fixture {
    fn drop(&mut self) {
        let _removed = std::fs::remove_dir_all(&self.root);
    }
}
