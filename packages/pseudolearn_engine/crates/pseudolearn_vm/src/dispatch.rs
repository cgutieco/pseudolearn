#![forbid(unsafe_code)]

use crate::Fault;
use crate::load::{Sentinel, Source};
use crate::machine::{Flow, Machine};

include!(concat!(env!("OUT_DIR"), "/generated_dispatch.rs"));
