use crate::class_layout::ClassDescriptor;
use crate::config::{AotLimits, BooleanWords};
use crate::fault::FaultSite;

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct ExecutableSettings {
    pub source_name: String,
    pub locale: String,
    pub seed: i64,
    pub forced_collection: bool,
    pub limits: AotLimits,
    pub boolean_words: BooleanWords,
    pub site_boolean_words: Vec<BooleanWords>,
    pub error_template: String,
    pub warning_template: String,
    pub information_template: String,
    pub exhausted_template: String,
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct ExecutableMetadata {
    pub settings: ExecutableSettings,
    pub sites: Vec<FaultSite>,
    pub classes: Vec<ClassDescriptor>,
}
