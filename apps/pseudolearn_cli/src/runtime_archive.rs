pub(crate) struct RuntimeArchive {
    pub(crate) triple: &'static str,
    pub(crate) archive: &'static [u8],
    pub(crate) support: &'static [(&'static str, &'static [u8])],
    pub(crate) imports: &'static str,
}

include!(concat!(env!("OUT_DIR"), "/runtime_archives.rs"));

pub(crate) fn archive_for(triple: &str) -> Option<&'static RuntimeArchive> {
    RUNTIME_ARCHIVES
        .iter()
        .find(|archive| archive.triple == triple)
}
