use crate::type_checker_helpers::TypeError;
use crate::{IrType, Operand, ValueClass, ValueId};

pub(crate) fn check(
    operands: &[Operand],
    get_type: &impl Fn(ValueId) -> Option<IrType>,
) -> Result<Option<IrType>, TypeError> {
    let Some(Operand::LiteralI64(count)) = operands.first() else {
        return Err(TypeError);
    };
    let count = usize::try_from(*count).map_err(|_| TypeError)?;
    let values = operands.get(1..).ok_or(TypeError)?;
    if count == 0 || count.checked_mul(2) != Some(values.len()) {
        return Err(TypeError);
    }
    let (sources, destinations) = values.split_at(count);
    for (source, destination) in sources.iter().zip(destinations) {
        let (Operand::Value(source), Operand::Value(destination)) = (source, destination) else {
            return Err(TypeError);
        };
        let kind = get_type(*source).ok_or(TypeError)?;
        if kind.value_class() != ValueClass::Reference
            || matches!(kind, IrType::Cell(_))
            || get_type(*destination) != Some(IrType::Cell(Box::new(kind)))
        {
            return Err(TypeError);
        }
    }
    Ok(Some(IrType::Unit))
}
