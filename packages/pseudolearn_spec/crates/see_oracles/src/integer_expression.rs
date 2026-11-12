#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum IntegerOperator {
    Add,
    Subtract,
    Multiply,
    Divide,
    Modulo,
    Power,
}

#[derive(Clone, Debug)]
pub enum IntegerExpression {
    Literal(i64),
    Binary {
        operator: IntegerOperator,
        origin: u32,
        left: Box<IntegerExpression>,
        right: Box<IntegerExpression>,
    },
}

#[derive(Clone, Debug, PartialEq, Eq)]
pub struct ArithmeticTrap {
    pub code: &'static str,
    pub origin: u32,
}

pub fn evaluate(expression: &IntegerExpression) -> Result<i64, ArithmeticTrap> {
    let mut pending = vec![(expression, false)];
    let mut values = Vec::new();
    while let Some((expression, visited)) = pending.pop() {
        match expression {
            IntegerExpression::Literal(value) => values.push(*value),
            IntegerExpression::Binary {
                operator,
                origin,
                left,
                right,
            } if visited => {
                let right = values
                    .pop()
                    .ok_or(trap("oracleInvalidExpression", *origin))?;
                let left = values
                    .pop()
                    .ok_or(trap("oracleInvalidExpression", *origin))?;
                values.push(operation(*operator, left, right).map_err(|code| trap(code, *origin))?);
            }
            IntegerExpression::Binary { left, right, .. } => {
                pending.push((expression, true));
                pending.push((right, false));
                pending.push((left, false));
            }
        }
    }
    values.pop().ok_or(trap("oracleInvalidExpression", 0))
}

fn trap(code: &'static str, origin: u32) -> ArithmeticTrap {
    ArithmeticTrap { code, origin }
}

pub fn operation(operator: IntegerOperator, left: i64, right: i64) -> Result<i64, &'static str> {
    let left = i128::from(left);
    let right = i128::from(right);
    let result = match operator {
        IntegerOperator::Add => left.checked_add(right),
        IntegerOperator::Subtract => left.checked_sub(right),
        IntegerOperator::Multiply => left.checked_mul(right),
        IntegerOperator::Divide | IntegerOperator::Modulo if right == 0 => {
            return Err("divisionByZero");
        }
        IntegerOperator::Divide => left.checked_div(right),
        IntegerOperator::Modulo => left.checked_rem(right),
        IntegerOperator::Power => return power(left, right),
    }
    .ok_or("integerOverflow")?;
    i64::try_from(result).map_err(|_| "integerOverflow")
}

fn power(base: i128, exponent: i128) -> Result<i64, &'static str> {
    if exponent < 0 {
        return Err("negativeIntegerExponent");
    }
    if base == 0 || base == 1 || base == -1 {
        return Ok(match (base, exponent) {
            (_, 0) | (1, _) => 1,
            (0, _) => 0,
            _ => {
                if exponent.checked_rem(2) == Some(0) {
                    1
                } else {
                    -1
                }
            }
        });
    }
    let exponent = u32::try_from(exponent).map_err(|_| "integerOverflow")?;
    let result = base.checked_pow(exponent).ok_or("integerOverflow")?;
    i64::try_from(result).map_err(|_| "integerOverflow")
}
