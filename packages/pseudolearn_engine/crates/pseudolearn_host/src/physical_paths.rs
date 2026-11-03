use crate::physical_request::{READ, WRITE};
use cap_std::{
    ambient_authority,
    fs::{Dir, File, OpenOptions},
};
use std::path::PathBuf;

pub(crate) enum DirectoryResource {
    Ambient(PathBuf),
    Confined(Dir),
}

impl DirectoryResource {
    pub(crate) fn open_file(&self, path: &str, rights: u8) -> std::io::Result<File> {
        match self {
            Self::Ambient(directory) => {
                let mut options = std::fs::OpenOptions::new();
                options.read(rights & READ != 0);
                if rights & WRITE != 0 {
                    options.write(true).create(true).truncate(true);
                }
                options.open(directory.join(path)).map(File::from_std)
            }
            Self::Confined(directory) => {
                crate::physical_request::checked_path(path)
                    .map_err(|_| std::io::Error::from(std::io::ErrorKind::InvalidInput))?;
                directory.open_with(path, &options(rights))
            }
        }
    }

    pub(crate) fn derive(&self, path: &str) -> std::io::Result<Self> {
        match self {
            Self::Ambient(directory) => {
                Dir::open_ambient_dir(directory.join(path), ambient_authority())
            }
            Self::Confined(directory) => directory.open_dir(path),
        }
        .map(Self::Confined)
    }
}

fn options(rights: u8) -> OpenOptions {
    let mut chosen = OpenOptions::new();
    chosen.read(rights & READ != 0);
    if rights & WRITE != 0 {
        chosen.write(true).create(true).truncate(true);
    }
    chosen
}
