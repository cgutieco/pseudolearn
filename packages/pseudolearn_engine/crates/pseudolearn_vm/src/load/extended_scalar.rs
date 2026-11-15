use super::operands::{scalar_destination, scalar_sources};
use super::{LoadedFunction, Source, invalid_bytecode};
use crate::dispatch::Op;
use crate::evaluate;
use crate::{Fault, VmTrap};
use pseudolearn_bytecode::{BytecodeFunction, Instruction};

#[derive(Clone, Copy, Debug, PartialEq)]
pub(crate) enum Evaluation {
    Tangent,
    ArcSine,
    ArcCosine,
    Logarithm2,
    Logarithm10,
    Floor,
    Ceiling,
    ArcTangent2,
    RealMinimum,
    RealMaximum,
    IntegerMinimum,
    IntegerMaximum,
}

impl Evaluation {
    pub(crate) fn evaluate(self, left: u64, right: u64) -> Result<u64, Fault> {
        match self {
            Self::Tangent => evaluate::math_tan(left),
            Self::ArcSine => evaluate::math_asin(left),
            Self::ArcCosine => evaluate::math_acos(left),
            Self::Logarithm2 => evaluate::math_log2(left),
            Self::Logarithm10 => evaluate::math_log10(left),
            Self::Floor => evaluate::real_floor(left),
            Self::Ceiling => evaluate::real_ceil(left),
            Self::ArcTangent2 => evaluate::math_atan2(left, right),
            Self::RealMinimum => evaluate::real_min(left, right),
            Self::RealMaximum => evaluate::real_max(left, right),
            Self::IntegerMinimum => evaluate::int_min(left, right),
            Self::IntegerMaximum => evaluate::int_max(left, right),
        }
    }
}

#[derive(Clone, Copy, Debug, PartialEq)]
pub(crate) struct ScalarSite {
    pub destination: u16,
    pub left: Source,
    pub right: Option<Source>,
    pub evaluation: Evaluation,
}

pub(super) fn decode(
    function: &BytecodeFunction,
    loaded: &mut LoadedFunction,
    instruction: &Instruction,
) -> Result<Op, VmTrap> {
    let sources = scalar_sources(function, instruction)?;
    let evaluation = evaluation(instruction.opcode.as_name()).ok_or_else(invalid_bytecode)?;
    let expected = if !matches!(
        evaluation,
        Evaluation::ArcTangent2
            | Evaluation::RealMinimum
            | Evaluation::RealMaximum
            | Evaluation::IntegerMinimum
            | Evaluation::IntegerMaximum
    ) {
        1
    } else {
        2
    };
    if sources.len() != expected {
        return Err(invalid_bytecode());
    }
    let site = u32::try_from(loaded.extended_scalars.len()).map_err(|_| invalid_bytecode())?;
    loaded.extended_scalars.push(ScalarSite {
        destination: scalar_destination(instruction)?,
        left: *sources.first().ok_or_else(invalid_bytecode)?,
        right: sources.get(1).copied(),
        evaluation,
    });
    Ok(Op::ExtendedScalar { site })
}

fn evaluation(name: &str) -> Option<Evaluation> {
    Some(match name {
        "math.tan" => Evaluation::Tangent,
        "math.asin" => Evaluation::ArcSine,
        "math.acos" => Evaluation::ArcCosine,
        "math.log2" => Evaluation::Logarithm2,
        "math.log10" => Evaluation::Logarithm10,
        "real.floor" => Evaluation::Floor,
        "real.ceil" => Evaluation::Ceiling,
        "math.atan2" => Evaluation::ArcTangent2,
        "real.min" => Evaluation::RealMinimum,
        "real.max" => Evaluation::RealMaximum,
        "int.min" => Evaluation::IntegerMinimum,
        "int.max" => Evaluation::IntegerMaximum,
        _ => return None,
    })
}
