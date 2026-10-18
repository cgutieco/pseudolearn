use crate::native_linker::link_executable;
use std::io::Result;
use std::path::{Path, PathBuf};

const CAPACITY: usize = 32;

struct CachedExecutable {
    object: Vec<u8>,
    path: PathBuf,
}

pub struct ExecutableCache {
    directory: PathBuf,
    entries: Vec<CachedExecutable>,
    counter: u64,
}

impl ExecutableCache {
    pub fn create() -> Result<Self> {
        let nanos = std::time::SystemTime::now()
            .duration_since(std::time::UNIX_EPOCH)
            .map_or(0, |duration| duration.as_nanos());
        let directory =
            std::env::temp_dir().join(format!("pseudo_aot_{}_{nanos}", std::process::id()));
        std::fs::create_dir_all(&directory)?;
        Ok(Self {
            directory,
            entries: Vec::new(),
            counter: 0,
        })
    }

    pub fn directory(&self) -> &Path {
        &self.directory
    }

    pub fn executable_for(&mut self, object: &[u8]) -> Result<PathBuf> {
        if let Some(found) = self.entries.iter().find(|entry| entry.object == object) {
            return Ok(found.path.clone());
        }
        if self.entries.len() >= CAPACITY {
            let oldest = self.entries.remove(0);
            let _removed = std::fs::remove_file(oldest.path);
        }
        self.counter = self.counter.saturating_add(1);
        let path = self.directory.join(format!("program_{}", self.counter));
        link_executable(object, &path)?;
        self.entries.push(CachedExecutable {
            object: object.to_vec(),
            path: path.clone(),
        });
        Ok(path)
    }
}

impl Drop for ExecutableCache {
    fn drop(&mut self) {
        let _removed = std::fs::remove_dir_all(&self.directory);
    }
}
