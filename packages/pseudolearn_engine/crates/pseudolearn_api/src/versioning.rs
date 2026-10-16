pub const PROTOCOL_VERSION: &str = "see-protocol/1";
pub const ENGINE_VERSION: &str = "0.1.0";
pub const SUBJECT_NAME: &str = "engine";

pub fn supported_profiles() -> Vec<&'static str> {
    vec!["es", "en"]
}

pub fn supported_strictness() -> Vec<&'static str> {
    vec!["strict", "flexible"]
}

pub fn supported_capabilities() -> Vec<&'static str> {
    vec!["analyze", "ir", "execute", "observe", "seek", "gc_stress"]
}
