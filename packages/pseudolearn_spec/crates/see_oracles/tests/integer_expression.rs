use see_oracles::integer_expression::{
    ArithmeticTrap, IntegerExpression, IntegerOperator, evaluate, operation,
};

#[test]
fn computes_checked_domain_without_using_subject_arithmetic() {
    assert_eq!(
        operation(IntegerOperator::Multiply, i64::MIN, -1),
        Err("integerOverflow")
    );
    assert_eq!(
        operation(IntegerOperator::Divide, i64::MIN, -1),
        Err("integerOverflow")
    );
    assert_eq!(operation(IntegerOperator::Modulo, i64::MIN, -1), Ok(0));
    assert_eq!(
        operation(IntegerOperator::Divide, 1, 0),
        Err("divisionByZero")
    );
    assert_eq!(
        operation(IntegerOperator::Power, 2, -1),
        Err("negativeIntegerExponent")
    );
    assert_eq!(operation(IntegerOperator::Power, 0, 0), Ok(1));
    assert_eq!(operation(IntegerOperator::Power, -1, i64::MAX), Ok(-1));
    assert_eq!(
        operation(IntegerOperator::Power, 2, 62),
        Ok(4611686018427387904)
    );
    assert_eq!(
        operation(IntegerOperator::Power, 2, 63),
        Err("integerOverflow")
    );
}

#[test]
fn attributes_first_trap_to_leftmost_failing_operation() {
    let expression = IntegerExpression::Binary {
        operator: IntegerOperator::Add,
        origin: 3,
        left: Box::new(IntegerExpression::Binary {
            operator: IntegerOperator::Multiply,
            origin: 1,
            left: Box::new(IntegerExpression::Literal(i64::MAX)),
            right: Box::new(IntegerExpression::Literal(2)),
        }),
        right: Box::new(IntegerExpression::Binary {
            operator: IntegerOperator::Divide,
            origin: 2,
            left: Box::new(IntegerExpression::Literal(1)),
            right: Box::new(IntegerExpression::Literal(0)),
        }),
    };
    assert_eq!(
        evaluate(&expression),
        Err(ArithmeticTrap {
            code: "integerOverflow",
            origin: 1
        })
    );
    assert_eq!(
        evaluate(&IntegerExpression::Literal(i64::MIN)),
        Ok(i64::MIN)
    );
}
