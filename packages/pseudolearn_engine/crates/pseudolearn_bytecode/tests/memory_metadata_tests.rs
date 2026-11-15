use pseudolearn_bytecode::{
    BasicBlock, BytecodeError, BytecodeModule, CodeVariant, DefinitionState, Register,
    RegisterClass, compile_text, verify_bytecode,
};
use pseudolearn_ir::BlockId;

fn module(source: &str) -> Result<BytecodeModule, BytecodeError> {
    Ok(compile_text(source)?.module().clone())
}

fn safe_point_roots(variant: &CodeVariant) -> Option<Vec<Vec<u16>>> {
    variant
        .instructions
        .iter()
        .enumerate()
        .filter(|(_, instruction)| is_safe_point(instruction.opcode.as_name()))
        .map(|(index, _)| {
            let position = u32::try_from(index).ok()?;
            let roots = variant.roots.get(&position)?;
            Some(roots.iter().map(|register| register.index).collect())
        })
        .collect()
}

fn first_safe_point_position(variant: &CodeVariant) -> Option<u32> {
    variant
        .instructions
        .iter()
        .enumerate()
        .find(|(_, instruction)| is_safe_point(instruction.opcode.as_name()))
        .and_then(|(index, _)| u32::try_from(index).ok())
}

fn roots_by_block(variant: &CodeVariant, identifier: BlockId) -> Option<Vec<Vec<Register>>> {
    let block_index = variant
        .blocks
        .iter()
        .position(|block| block.identifier == identifier)?;
    let block = variant.blocks.get(block_index)?;
    let start = usize::try_from(block.start_pc).ok()?;
    let end = variant
        .blocks
        .get(block_index.checked_add(1)?)
        .and_then(|next| usize::try_from(next.start_pc).ok())
        .or_else(|| usize::try_from(variant.used_length).ok())?;
    variant
        .instructions
        .iter()
        .enumerate()
        .take(end)
        .skip(start)
        .filter(|(_, instruction)| is_safe_point(instruction.opcode.as_name()))
        .map(|(index, _)| {
            let position = u32::try_from(index).ok()?;
            variant.roots.get(&position).cloned()
        })
        .collect()
}

fn reference_parameters(block: &BasicBlock) -> Vec<Register> {
    block
        .parameters
        .iter()
        .filter(|register| register.class == RegisterClass::Reference)
        .copied()
        .collect()
}

fn is_safe_point(opcode: &str) -> bool {
    matches!(
        opcode,
        "call"
            | "call.virtual"
            | "array.new"
            | "object.new"
            | "object.copy"
            | "text.concat"
            | "text.format"
            | "in.read"
    )
}

#[test]
fn rejects_missing_root_and_definition_maps() -> Result<(), BytecodeError> {
    let source = "module P es\nfunc @main() -> unit {\nb0() mass 0:\n  %0 = const.str \"x\"\n  %1 = text.concat %0, %0 @1:1-1:2\n  return\n}\n";
    for probed in [false, true] {
        for definitions in [false, true] {
            let mut candidate = module(source)?;
            let function = candidate
                .functions
                .first_mut()
                .ok_or(BytecodeError::InvalidModule)?;
            let variant = if probed {
                &mut function.probed
            } else {
                &mut function.fast
            };
            if definitions {
                variant.definitions.clear();
            } else {
                variant.roots.clear();
            }
            assert!(verify_bytecode(&candidate).is_err());
        }
    }
    Ok(())
}

#[test]
fn rejects_root_classes_offsets_and_duplicate_entries() -> Result<(), BytecodeError> {
    let source = "module P es\nfunc @main() -> unit {\nb0() mass 0:\n  %0 = const.str \"x\"\n  %1 = text.concat %0, %0 @1:1-1:2\n  return\n}\n";
    for root in [
        Register {
            class: RegisterClass::Scalar,
            index: 0,
        },
        Register {
            class: RegisterClass::Reference,
            index: u16::MAX,
        },
    ] {
        let mut candidate = module(source)?;
        let function = candidate
            .functions
            .first_mut()
            .ok_or(BytecodeError::InvalidModule)?;
        let roots = function
            .fast
            .roots
            .values_mut()
            .next()
            .ok_or(BytecodeError::InvalidModule)?;
        roots.push(root);
        assert!(verify_bytecode(&candidate).is_err());
    }
    let mut candidate = module(source)?;
    let function = candidate
        .functions
        .first_mut()
        .ok_or(BytecodeError::InvalidModule)?;
    function.fast.roots.insert(u32::MAX, Vec::new());
    assert!(verify_bytecode(&candidate).is_err());

    let mut duplicate = module(source)?;
    let function = duplicate
        .functions
        .first_mut()
        .ok_or(BytecodeError::InvalidModule)?;
    let roots = function
        .fast
        .roots
        .values_mut()
        .next()
        .ok_or(BytecodeError::InvalidModule)?;
    let root = roots.first().copied().ok_or(BytecodeError::InvalidModule)?;
    roots.push(root);
    assert!(verify_bytecode(&duplicate).is_err());
    Ok(())
}

#[test]
fn rejects_invalid_definition_maps() -> Result<(), BytecodeError> {
    let source = "module P es\nfunc @main() -> unit {\nb0() mass 0:\n  %0 = const.str \"x\"\n  %1 = text.concat %0, %0 @1:1-1:2\n  return\n}\n";
    let mut invalid_register = module(source)?;
    let function = invalid_register
        .functions
        .first_mut()
        .ok_or(BytecodeError::InvalidModule)?;
    let position = first_safe_point_position(&function.fast).ok_or(BytecodeError::InvalidModule)?;
    function
        .fast
        .definitions
        .get_mut(&position)
        .ok_or(BytecodeError::InvalidModule)?
        .insert(
            Register {
                class: RegisterClass::Reference,
                index: u16::MAX,
            },
            DefinitionState::Defined,
        );
    assert!(verify_bytecode(&invalid_register).is_err());

    let mut missing_operand = module(source)?;
    let function = missing_operand
        .functions
        .first_mut()
        .ok_or(BytecodeError::InvalidModule)?;
    let position = first_safe_point_position(&function.fast).ok_or(BytecodeError::InvalidModule)?;
    let instruction = function
        .fast
        .instructions
        .get(usize::try_from(position).map_err(|_| BytecodeError::InvalidModule)?)
        .ok_or(BytecodeError::InvalidModule)?;
    let operand = instruction
        .operands
        .iter()
        .find_map(|operand| match operand {
            pseudolearn_bytecode::BytecodeOperand::Register(register) => Some(*register),
            _ => None,
        })
        .ok_or(BytecodeError::InvalidModule)?;
    function
        .fast
        .definitions
        .get_mut(&position)
        .ok_or(BytecodeError::InvalidModule)?
        .remove(&operand);
    assert!(verify_bytecode(&missing_operand).is_err());

    let mut invalid_offset = module(source)?;
    let function = invalid_offset
        .functions
        .first_mut()
        .ok_or(BytecodeError::InvalidModule)?;
    function
        .fast
        .definitions
        .insert(u32::MAX, std::collections::BTreeMap::new());
    assert!(verify_bytecode(&invalid_offset).is_err());
    Ok(())
}

#[test]
fn exact_roots_keep_live_literals_and_expire_dead_temporaries() -> Result<(), BytecodeError> {
    let source = "module P es\nfunc @main() -> unit {\nb0() mass 0:\n  %0 = const.str \"x\"\n  %1 = text.concat %0, %0 @1:1-1:2\n  %2 = text.concat %1, %0 @1:1-1:2\n  out.write %2 @1:1-1:2\n  %3 = text.concat %0, %0 @1:1-1:2\n  out.write %3 @1:1-1:2\n  return\n}\n";
    let candidate = module(source)?;
    let function = candidate
        .functions
        .first()
        .ok_or(BytecodeError::InvalidModule)?;
    let expected = Some(vec![vec![0], vec![0, 1], vec![0]]);
    assert_eq!(safe_point_roots(&function.fast), expected);
    assert_eq!(safe_point_roots(&function.probed), expected);
    assert_eq!(verify_bytecode(&candidate), Ok(()));
    Ok(())
}

#[test]
fn exact_roots_follow_branch_arguments_and_loop_back_edges() -> Result<(), BytecodeError> {
    let source = "module P es\nfunc @main(%0: str, %1: str) -> unit {\nb0() mass 0:\n  %2 = const.i64 0\n  jump b1(%2, %0, %1)\nb1(%3: i64, %4: str, %5: str) mass 0:\n  %6 = const.str \"x\"\n  %7 = text.concat %4, %6 @1:1-1:2\n  %8 = const.i64 1\n  %9 = int.add %3, %8 @1:1-1:2\n  %10 = const.i64 2\n  %11 = int.cmp lt, %9, %10 @1:1-1:2\n  decide.bool %11 @1:1-1:2\n  branch %11, b2(%9, %7, %5), b3(%7, %5)\nb2(%12: i64, %13: str, %14: str) mass 0:\n  %15 = text.concat %13, %13 @1:1-1:2\n  jump b1(%12, %15, %14)\nb3(%16: str, %17: str) mass 0:\n  %18 = text.concat %16, %16 @1:1-1:2\n  out.write %18 @1:1-1:2\n  %19 = text.concat %17, %17 @1:1-1:2\n  out.write %19 @1:1-1:2\n  return\n}\n";
    let candidate = module(source)?;
    let function = candidate
        .functions
        .first()
        .ok_or(BytecodeError::InvalidModule)?;
    let first_block = function
        .fast
        .blocks
        .iter()
        .find(|block| block.identifier == BlockId(1))
        .ok_or(BytecodeError::MissingBlock)?;
    let literal = function
        .fast
        .instructions
        .iter()
        .find(|instruction| instruction.opcode.as_name() == "const.str")
        .and_then(|instruction| instruction.destination)
        .ok_or(BytecodeError::InvalidModule)?;
    let mut first_expected = reference_parameters(first_block);
    first_expected.push(literal);
    first_expected.sort();
    let second_expected = reference_parameters(
        function
            .fast
            .blocks
            .iter()
            .find(|block| block.identifier == BlockId(2))
            .ok_or(BytecodeError::MissingBlock)?,
    );
    let third_expected = reference_parameters(
        function
            .fast
            .blocks
            .iter()
            .find(|block| block.identifier == BlockId(3))
            .ok_or(BytecodeError::MissingBlock)?,
    );
    let fourth_expected = third_expected.get(1).copied();
    let expected = vec![
        vec![first_expected],
        vec![second_expected],
        vec![
            third_expected,
            vec![fourth_expected.ok_or(BytecodeError::InvalidModule)?],
        ],
    ];
    for variant in [&function.fast, &function.probed] {
        let actual = [BlockId(1), BlockId(2), BlockId(3)]
            .iter()
            .map(|identifier| roots_by_block(variant, *identifier))
            .collect::<Option<Vec<_>>>()
            .ok_or(BytecodeError::InvalidModule)?;
        assert_eq!(actual, expected);
    }
    assert_eq!(verify_bytecode(&candidate), Ok(()));
    Ok(())
}
