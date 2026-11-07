use pseudolearn_semantic::hir::{HirClass, HirFunction, HirLocal, HirRecord};
use pseudolearn_semantic::variant_model::{HirVariant, VariantFamily};
use pseudolearn_semantic::{
    ClassId, ExpressionId, FunctionId, HirExpression, HirModule, HirStatement, LocalId, RecordId,
    StatementId, Type, TypeId,
};
use pseudolearn_source::Span;

pub(crate) struct ModuleView<'module> {
    pub(crate) module: &'module HirModule,
}

fn position(identifier: u32) -> usize {
    usize::try_from(identifier).unwrap_or(usize::MAX)
}

pub(crate) enum RecordRole<'module> {
    Plain(&'module HirRecord),
    Channel(TypeId),
    Variant(&'module HirVariant, RecordId),
    Function(&'module pseudolearn_semantic::function_model::FunctionSignature),
    TaskFailure,
    Unknown,
}

impl<'module> ModuleView<'module> {
    pub(crate) fn new(module: &'module HirModule) -> Self {
        Self { module }
    }

    pub(crate) fn expression(&self, identifier: ExpressionId) -> &'module HirExpression {
        self.module
            .expressions
            .kinds
            .get(position(identifier.0))
            .unwrap_or(&HirExpression::Invalid)
    }

    pub(crate) fn expression_type(&self, identifier: ExpressionId) -> Type {
        self.module
            .expressions
            .types
            .get(position(identifier.0))
            .map_or(Type::Error, |type_id| self.representation(*type_id))
    }

    pub(crate) fn expression_type_id(&self, identifier: ExpressionId) -> Option<TypeId> {
        self.module
            .expressions
            .types
            .get(position(identifier.0))
            .copied()
    }

    pub(crate) fn expression_span(&self, identifier: ExpressionId) -> Span {
        self.module
            .expressions
            .spans
            .get(position(identifier.0))
            .copied()
            .unwrap_or_default()
    }

    pub(crate) fn statement(&self, identifier: StatementId) -> Option<&'module HirStatement> {
        self.module.statements.kinds.get(position(identifier.0))
    }

    pub(crate) fn statement_span(&self, identifier: StatementId) -> Span {
        self.module
            .statements
            .spans
            .get(position(identifier.0))
            .copied()
            .unwrap_or_default()
    }

    pub(crate) fn local(&self, identifier: LocalId) -> Option<&'module HirLocal> {
        self.module.locals.get(position(identifier.0))
    }

    pub(crate) fn function(&self, identifier: FunctionId) -> Option<&'module HirFunction> {
        self.module.functions.get(position(identifier.0))
    }

    pub(crate) fn class(&self, identifier: ClassId) -> Option<&'module HirClass> {
        self.module.classes.get(position(identifier.0))
    }

    pub(crate) fn representation(&self, type_id: TypeId) -> Type {
        self.module.types.representation(type_id)
    }

    pub(crate) fn record(&self, identifier: RecordId) -> Option<&'module HirRecord> {
        self.module.records.get(position(identifier.0))
    }

    pub(crate) fn record_role(&self, identifier: RecordId) -> RecordRole<'module> {
        if let Some(element) = self.module.channels.get(&identifier) {
            return RecordRole::Channel(*element);
        }
        if let Some(variant) = self.module.variants.get(&identifier) {
            return RecordRole::Variant(variant, identifier);
        }
        if let Some(signature) = self.module.function_types.get(&identifier) {
            return RecordRole::Function(signature);
        }
        if self.module.task_failures.contains_key(&identifier) {
            return RecordRole::TaskFailure;
        }
        self.record(identifier)
            .map_or(RecordRole::Unknown, RecordRole::Plain)
    }

    pub(crate) fn variant_family(&self, identifier: RecordId) -> Option<VariantFamily> {
        self.module
            .variants
            .get(&identifier)
            .map(|variant| variant.family)
    }

    pub(crate) fn local_name(&self, identifier: LocalId) -> String {
        self.local(identifier).map_or_else(
            || format!("local{}", identifier.0),
            |local| local.name.clone(),
        )
    }

    pub(crate) fn expression_type_id_of_function_value(
        &self,
        function: FunctionId,
    ) -> Option<TypeId> {
        self.module
            .expressions
            .kinds
            .iter()
            .position(
                |kind| matches!(kind, HirExpression::FunctionValue(found) if *found == function),
            )
            .and_then(|index| self.module.expressions.types.get(index).copied())
    }

    pub(crate) fn failure_record(&self, local: LocalId) -> Option<RecordId> {
        let Type::Record(optional) = self.representation(self.local(local)?.type_id) else {
            return None;
        };
        let payload = self
            .module
            .variants
            .get(&optional)?
            .payloads
            .get(1)
            .copied()
            .flatten()?;
        match self.representation(payload) {
            Type::Record(record) if self.module.task_failures.contains_key(&record) => Some(record),
            _ => None,
        }
    }

    pub(crate) fn returns_result(&self, function: FunctionId) -> bool {
        self.function(function)
            .is_some_and(|entry| match self.representation(entry.result) {
                Type::Record(record) => self.variant_family(record) == Some(VariantFamily::Result),
                _ => false,
            })
    }

    pub(crate) fn is_opaque(&self, type_id: TypeId) -> bool {
        match self.representation(type_id) {
            Type::Record(record) => {
                self.record(record)
                    .is_some_and(|entry| entry.fields.is_empty())
                    && matches!(self.record_role(record), RecordRole::Plain(_))
            }
            Type::Array { element, .. } => self.is_opaque(element),
            _ => false,
        }
    }

    pub(crate) fn is_template_variant(&self, record: RecordId) -> bool {
        self.module
            .user_variants
            .get(&record)
            .is_some_and(|variant| {
                variant
                    .alternatives
                    .iter()
                    .filter_map(|alternative| alternative.payload)
                    .any(|payload| {
                        self.record(payload).is_some_and(|entry| {
                            entry
                                .fields
                                .iter()
                                .any(|field| self.is_opaque(field.type_id))
                        })
                    })
            })
    }

    pub(crate) fn is_template_class(&self, class: ClassId) -> bool {
        self.class(class).is_some_and(|entry| {
            entry
                .fields
                .iter()
                .any(|field| self.is_opaque(field.type_id))
        })
    }

    pub(crate) fn is_record_leaf(&self, identifier: LocalId) -> bool {
        self.module
            .record_locals
            .values()
            .any(|leaves| leaves.contains(&identifier))
    }
}
