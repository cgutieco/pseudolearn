#![forbid(unsafe_code)]

use crate::abi_signatures::RuntimeImports;
use crate::block_accounting::StatementCharging;
use crate::class_table::ClassTable;
use crate::context_layout::ContextLayout;
use crate::entry_point::{EntryPoint, define_entry_point};
use crate::error::CodegenError;
use crate::fault_table::FaultTable;
use crate::function_compiler::compile_function;
use crate::lowering::FunctionEnvironment;
use crate::target::TargetConfig;
use crate::type_mapping::extend_signature;
use cranelift_codegen::Context;
use cranelift_codegen::ir::{Function as ClifFunction, UserFuncName};
use cranelift_module::{
    DataDescription, DataId, FuncId, Linkage, Module as ClifModule, default_libcall_names,
};
use cranelift_object::{ObjectBuilder, ObjectModule};
use pseudolearn_aot_rt::{
    ClassDescriptor, ExecutableMetadata, ExecutableSettings, FaultSite, encode_metadata,
};
use pseudolearn_ir::{Module, Operand, Operation};
use std::collections::{BTreeSet, HashMap};

const ENTRY_FUNCTION_NAME: &str = "main";

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct FunctionSymbol {
    pub name: String,
    pub symbol: String,
}

#[derive(Debug)]
pub struct CompiledObject {
    pub bytes: Vec<u8>,
    pub fault_sites: Vec<FaultSite>,
    pub function_symbols: Vec<FunctionSymbol>,
    pub classes: Vec<ClassDescriptor>,
}

pub fn function_symbol(index: usize) -> String {
    format!("__pl_fn_{index}")
}

#[derive(Clone, Copy)]
pub(crate) enum EmissionMode<'settings> {
    Library,
    Executable(&'settings ExecutableSettings),
    Benchmark(&'settings ExecutableSettings),
}

pub(crate) fn emit_module(
    module: &Module,
    target: &TargetConfig,
    mode: EmissionMode<'_>,
) -> Result<CompiledObject, CodegenError> {
    let isa = target.build_isa()?;
    let builder = ObjectBuilder::new(isa, module.name.clone(), default_libcall_names())
        .map_err(CodegenError::backend)?;
    let mut object = ObjectModule::new(builder);
    let pointer = object.isa().pointer_type();
    let imports = RuntimeImports::declare(&mut object, pointer)?;
    let identifiers = declare_functions(&mut object, module)?;
    let classes = ClassTable::build(module)?;
    let literals = define_literals(&mut object, module)?;
    let declarations = Declarations {
        imports: &imports,
        identifiers: &identifiers,
        literals: &literals,
        classes: &classes,
        charging: charging_of(mode),
    };
    let faults = define_functions(&mut object, module, &declarations)?;
    let fault_sites = faults.into_sites();
    let descriptors = classes.descriptors()?;
    if let EmissionMode::Executable(settings) = mode {
        let metadata = ExecutableMetadata {
            settings: settings.clone(),
            sites: fault_sites.clone(),
            classes: descriptors.clone(),
        };
        attach_entry_point(&mut object, module, &identifiers, &metadata)?;
    }
    let bytes = object.finish().emit().map_err(CodegenError::backend)?;
    Ok(CompiledObject {
        bytes,
        fault_sites,
        function_symbols: symbols_of(module),
        classes: descriptors,
    })
}

fn charging_of(mode: EmissionMode<'_>) -> StatementCharging {
    match mode {
        EmissionMode::Library => StatementCharging::PerBlock,
        EmissionMode::Executable(settings) | EmissionMode::Benchmark(settings) => {
            if settings.limits.instruction_units.is_some() {
                StatementCharging::PerStatement
            } else {
                StatementCharging::Disabled
            }
        }
    }
}

fn attach_entry_point(
    object: &mut ObjectModule,
    module: &Module,
    identifiers: &[FuncId],
    metadata: &ExecutableMetadata,
) -> Result<(), CodegenError> {
    let function = *identifiers
        .get(entry_index(module)?)
        .ok_or(CodegenError::InvalidModule("undeclared entry function"))?;
    let encoded = encode_metadata(metadata);
    define_entry_point(
        object,
        &EntryPoint {
            function,
            metadata: &encoded,
        },
    )
}

fn define_functions(
    object: &mut ObjectModule,
    module: &Module,
    declarations: &Declarations<'_>,
) -> Result<FaultTable, CodegenError> {
    let mut faults = FaultTable::default();
    for (index, function) in module.functions.iter().enumerate() {
        let identifier = *declarations
            .identifiers
            .get(index)
            .ok_or(CodegenError::InvalidModule("undeclared function"))?;
        let unit = FunctionUnit {
            module,
            function,
            index,
            identifier,
        };
        define_function(object, declarations, &unit, &mut faults)?;
    }
    Ok(faults)
}

fn entry_index(module: &Module) -> Result<usize, CodegenError> {
    module
        .functions
        .iter()
        .position(|function| function.name.trim_start_matches('@') == ENTRY_FUNCTION_NAME)
        .ok_or(CodegenError::InvalidModule("module without main function"))
}

struct FunctionUnit<'program> {
    module: &'program Module,
    function: &'program pseudolearn_ir::Function,
    index: usize,
    identifier: FuncId,
}

struct Declarations<'program> {
    imports: &'program RuntimeImports,
    identifiers: &'program [FuncId],
    literals: &'program [(String, DataId)],
    classes: &'program ClassTable,
    charging: StatementCharging,
}

fn define_function(
    object: &mut ObjectModule,
    declarations: &Declarations<'_>,
    unit: &FunctionUnit<'_>,
    faults: &mut FaultTable,
) -> Result<(), CodegenError> {
    let mut clif = ClifFunction::with_name_signature(
        UserFuncName::user(0, u32::try_from(unit.index).unwrap_or(0)),
        signature_of(object, unit.function),
    );
    let environment = FunctionEnvironment {
        module: unit.module,
        frontend: object.isa().frontend_config(),
        layout: ContextLayout::new()?,
        runtime: declarations.imports.import_into(object, &mut clif),
        callees: declarations
            .identifiers
            .iter()
            .map(|callee| object.declare_func_in_func(*callee, &mut clif))
            .collect(),
        literals: declarations
            .literals
            .iter()
            .map(|(content, storage)| {
                (
                    content.clone(),
                    object.declare_data_in_func(*storage, &mut clif),
                )
            })
            .collect::<HashMap<_, _>>(),
        classes: declarations.classes,
        charging: declarations.charging,
    };
    compile_function(unit.function, &environment, &mut clif, faults)?;
    let mut context = Context::for_function(clif);
    object
        .define_function(unit.identifier, &mut context)
        .map_err(CodegenError::backend)?;
    Ok(())
}

fn signature_of(
    object: &ObjectModule,
    function: &pseudolearn_ir::Function,
) -> cranelift_codegen::ir::Signature {
    let mut signature = object.make_signature();
    extend_signature(&mut signature, object.isa().pointer_type(), function);
    signature
}

fn declare_functions(
    object: &mut ObjectModule,
    module: &Module,
) -> Result<Vec<FuncId>, CodegenError> {
    let mut identifiers = Vec::new();
    for (index, function) in module.functions.iter().enumerate() {
        let signature = signature_of(object, function);
        let identifier = object
            .declare_function(&function_symbol(index), Linkage::Export, &signature)
            .map_err(CodegenError::backend)?;
        identifiers.push(identifier);
    }
    Ok(identifiers)
}

fn symbols_of(module: &Module) -> Vec<FunctionSymbol> {
    module
        .functions
        .iter()
        .enumerate()
        .map(|(index, function)| FunctionSymbol {
            name: function.name.clone(),
            symbol: function_symbol(index),
        })
        .collect()
}

fn define_literals(
    object: &mut ObjectModule,
    module: &Module,
) -> Result<Vec<(String, DataId)>, CodegenError> {
    let mut contents = BTreeSet::new();
    for function in &module.functions {
        for block in &function.blocks {
            for instruction in &block.instructions {
                collect_literal(function, *instruction, &mut contents);
            }
        }
    }
    let mut defined = Vec::new();
    for (position, content) in contents.into_iter().enumerate() {
        let name = format!("__pl_str_{position}");
        let storage = object
            .declare_data(&name, Linkage::Local, false, false)
            .map_err(CodegenError::backend)?;
        let mut description = DataDescription::new();
        let mut bytes = content.as_bytes().to_vec();
        bytes.push(0);
        description.define(bytes.into_boxed_slice());
        object
            .define_data(storage, &description)
            .map_err(CodegenError::backend)?;
        defined.push((content, storage));
    }
    Ok(defined)
}

fn collect_literal(
    function: &pseudolearn_ir::Function,
    instruction: pseudolearn_ir::InstructionId,
    contents: &mut BTreeSet<String>,
) {
    if function.columns.operation(instruction) != Some(Operation::ConstStr) {
        return;
    }
    if let Some(Operand::LiteralStr(content)) = function.columns.operands(instruction).first() {
        contents.insert(content.clone());
    }
}
