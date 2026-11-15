use std::path::{Path, PathBuf};

pub struct Fixture {
    pub root: PathBuf,
}

impl Fixture {
    pub fn create() -> Result<Self, Box<dyn std::error::Error>> {
        static NEXT: std::sync::atomic::AtomicUsize = std::sync::atomic::AtomicUsize::new(0);
        let sequence = NEXT.fetch_add(1, std::sync::atomic::Ordering::Relaxed);
        let root = std::env::temp_dir().join(format!(
            "pseudolearn-check-{}-{sequence}",
            std::process::id()
        ));
        std::fs::create_dir_all(root.join("subject/src"))?;
        std::fs::write(
            root.join("Cargo.toml"),
            "[workspace]\nmembers = [\"subject\"]\nresolver = \"3\"\n",
        )?;
        std::fs::write(
            root.join("subject/Cargo.toml"),
            "[package]\nname = \"subject\"\nversion = \"0.1.0\"\nedition = \"2024\"\npublish = false\n",
        )?;
        std::fs::write(root.join("subject/src/lib.rs"), "pub fn execute() {}\n")?;
        std::fs::write(root.join("subject/README.md"), "# Subject\n")?;
        Ok(Self { root })
    }

    pub fn source(
        &self,
    ) -> Result<pseudolearn_check_source::loading::SourceFile, Box<dyn std::error::Error>> {
        let path = self.root.join("subject/src/lib.rs");
        let text = std::fs::read_to_string(&path)?;
        Ok(pseudolearn_check_source::loading::SourceFile {
            path,
            relative: "subject/src/lib.rs".to_owned(),
            syntax: syn::parse_file(&text)?,
            text,
            layer: 0,
            is_test: false,
        })
    }

    pub fn rules(&self) -> Result<pseudolearn_check_model::Architecture, String> {
        let origin = Path::new(env!("CARGO_MANIFEST_DIR")).join("../..");
        let mut rules = pseudolearn_check_source::loading::read_architecture(&origin)?;
        rules.layers.truncate(1);
        let layer = rules.layers.first_mut().ok_or("Missing fixture layer")?;
        layer.name = "subject".to_owned();
        layer.path = "subject".to_owned();
        layer.may_import.clear();
        layer.external_dependencies.clear();
        Ok(rules)
    }
}

impl Drop for Fixture {
    fn drop(&mut self) {
        let _cleanup = std::fs::remove_dir_all(&self.root);
    }
}
