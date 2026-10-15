#![forbid(unsafe_code)]

mod integer;
mod interval;
mod natural;

#[cfg(test)]
mod integer_tests;
#[cfg(test)]
mod interval_tests;
#[cfg(test)]
mod natural_tests;

pub(crate) use integer::Integer;
pub(crate) use interval::Interval;
pub(crate) use natural::Natural;
