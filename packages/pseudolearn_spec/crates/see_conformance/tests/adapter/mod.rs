use std::path::PathBuf;
use std::process::Command;

pub struct Adapter {
    root: PathBuf,
    pub binary: PathBuf,
}

impl Adapter {
    pub fn create() -> Result<Self, String> {
        static NEXT: std::sync::atomic::AtomicUsize = std::sync::atomic::AtomicUsize::new(0);
        let sequence = NEXT.fetch_add(1, std::sync::atomic::Ordering::Relaxed);
        let root =
            std::env::temp_dir().join(format!("see-adapter-{}-{sequence}", std::process::id()));
        std::fs::create_dir_all(&root).map_err(|error| error.to_string())?;
        let binary = root.join(format!("adapter{}", std::env::consts::EXE_SUFFIX));
        let source = PathBuf::from(env!("CARGO_MANIFEST_DIR"))
            .join("../../fixtures/adapters/subject.rs.txt");
        let status = Command::new("rustc")
            .args(["--crate-name", "subject", "--edition", "2024"])
            .arg(source)
            .arg("-o")
            .arg(&binary)
            .status()
            .map_err(|error| error.to_string())?;
        if !status.success() {
            return Err("Cannot compile test adapter".to_owned());
        }
        Ok(Self { root, binary })
    }

    pub fn command(&self, mode: &str) -> Command {
        let mut command = Command::new(&self.binary);
        command.arg(mode);
        command
    }
}

impl Drop for Adapter {
    fn drop(&mut self) {
        let _removed = std::fs::remove_dir_all(&self.root);
    }
}
