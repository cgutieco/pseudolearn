use serde::{Deserialize, Serialize};
use serde_json::Value;

#[derive(Clone, Debug, Deserialize, Serialize, PartialEq)]
#[serde(deny_unknown_fields)]
pub struct PropertyRun {
    pub specification: String,
    pub property: String,
    pub seed: u64,
    pub samples: u32,
    pub completed: u32,
    pub verdict: String,
    pub counterexample: Option<Counterexample>,
}

#[derive(Clone, Debug, Deserialize, Serialize, PartialEq)]
#[serde(deny_unknown_fields)]
pub struct Counterexample {
    pub sample: u32,
    pub profile: String,
    pub strictness: String,
    pub program: String,
    pub expected: Value,
    pub actual: Value,
    pub reproduction: Vec<String>,
}

#[derive(Clone, Debug, Deserialize, Serialize)]
#[serde(deny_unknown_fields)]
pub struct PropertyRegistry {
    pub format: String,
    pub subjects: Vec<String>,
    pub entries: Vec<PropertyBinding>,
}

#[derive(Clone, Debug, Deserialize, Serialize)]
#[serde(deny_unknown_fields)]
pub struct PropertyBinding {
    pub reference: String,
    pub executor: PropertyExecutor,
    pub seed: u64,
    pub samples: u32,
}

#[derive(Clone, Copy, Debug, Deserialize, Serialize, PartialEq, Eq)]
#[serde(rename_all = "snake_case")]
pub enum PropertyExecutor {
    NativeEquivalence,
    NativeRoots,
    NativeDiagnostics,
    NativeLinking,
    NativeCleanup,
    NativePermissions,
    NativeExit,
    NativeEnvironment,
    Determinism,
    FirstTrap,
    InputBatching,
    StepPartition,
    StepDepth,
    SnapshotIsolation,
    DeltaReconstruction,
    DeltaMinimality,
    PastStateIsolation,
    IdentityStability,
    GcTransparency,
    LoweringValidity,
    LoweringExecution,
    StatementMass,
    ObservationCorrespondence,
    ExecutionControls,
    StateQuery,
    WireRoundtrip,
    VersionNegotiation,
    CapabilityNegotiation,
    HostRecording,
    CliIrRoundtrip,
    AnalysisSchema,
    UsageErrors,
    InternalFaultContainment,
    ResourceLifecycle,
    InterfaceLanguage,
    FusedFirstTrap,
    LosslessReprint,
    LosslessRecovery,
}
