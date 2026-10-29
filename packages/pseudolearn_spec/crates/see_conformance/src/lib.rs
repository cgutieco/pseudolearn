#![forbid(unsafe_code)]

pub mod comparison;
pub mod execution;
pub mod math_arguments;
pub mod math_contrast;
mod math_power_arguments;
mod math_sampling;
pub mod memory_fixtures;
pub mod protocol;
mod recording_replay;
mod recording_tape_mutation;
pub mod requests;
pub mod runtime_fixtures;
pub mod tool_comparison;

pub mod properties;
mod property_api;
mod property_comparison;
mod property_evidence;
mod property_json_roundtrip;
mod property_recording;
mod property_resources;
mod property_scenarios;
mod property_service;
mod property_states;
mod property_steps;
mod property_syntax;
mod property_traps;

pub mod target_programs;

mod property_observation;

mod property_revision;

pub mod event_identity;

#[cfg(test)]
mod property_revision_tests;

mod property_cli;

#[cfg(test)]
mod property_cli_tests;

#[cfg(test)]
mod property_traps_tests;

#[cfg(test)]
mod property_recording_tests;
