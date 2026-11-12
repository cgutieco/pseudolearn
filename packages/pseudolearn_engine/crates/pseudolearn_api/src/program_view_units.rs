use crate::ApiUnit;
use serde_json::{Value, json};

pub(crate) fn units(
    schema: &[ApiUnit],
    nodes: &[crate::program_view::ViewNode],
    revision: &str,
    source: Option<crate::ApiSourceIdentity>,
) -> Value {
    UnitProjection {
        nodes,
        revision,
        source,
    }
    .project(schema)
}

struct UnitProjection<'unit> {
    nodes: &'unit [crate::program_view::ViewNode],
    revision: &'unit str,
    source: Option<crate::ApiSourceIdentity>,
}

impl UnitProjection<'_> {
    fn project(&self, schema: &[ApiUnit]) -> Value {
        Value::Array(
            schema
                .iter()
                .enumerate()
                .map(|(order, unit)| self.unit_value(order, unit))
                .collect(),
        )
    }

    fn unit_value(&self, order: usize, unit: &ApiUnit) -> Value {
        let syntax_kind = match unit.kind.as_str() {
            "algorithm" => "algorithm_unit",
            "class" => "class_unit",
            _ => "subroutine",
        };
        let (node_id, span) = self.node_reference(unit, syntax_kind);
        json!({
            "kind":unit.kind,
            "name":unit.name,
            "order":order,
            "node_id":node_id,
            "span":span
        })
    }

    fn node_reference(&self, unit: &ApiUnit, syntax_kind: &str) -> (Value, Value) {
        let node = self.nodes.iter().enumerate().find(|(_, node)| {
            node.syntax_kind == syntax_kind
                && node.start == (unit.span.start.line, unit.span.start.column)
                && node.end == (unit.span.end.line, unit.span.end.column)
        });
        node.map_or_else(
            || (Value::Null, Value::Null),
            |(index, node)| {
                (
                    json!(crate::program_view::node_identifier(
                        self.revision,
                        self.source,
                        index
                    )),
                    json!({
                        "start_byte": node.start_byte.to_string(),
                        "end_byte": node.end_byte.to_string(),
                        "start": {"line": node.start.0, "column": node.start.1},
                        "end": {"line": node.end.0, "column": node.end.1}
                    }),
                )
            },
        )
    }
}
