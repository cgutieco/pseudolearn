use see_oracles::cells::{Allocation, AllocationKind, reachable_cells};
use serde_json::{Value, json};
use std::collections::BTreeMap;

pub fn generate(
    seed: u64,
    samples: u32,
    vocabulary: &see_model::contract::Vocabulary,
) -> Result<Vec<Value>, String> {
    let mut random = seed;
    let mut fixtures = Vec::new();
    for sample in 0..samples {
        let mut fixture = scenario(&mut random, sample)?;
        let source = fixture
            .get("program")
            .and_then(Value::as_str)
            .ok_or("Missing memory program")?;
        let english = see_translation::translate(source, "es", "en", vocabulary)?;
        fixture
            .as_object_mut()
            .ok_or("Invalid memory fixture")?
            .insert("english".to_owned(), json!(english));
        fixtures.push(fixture);
    }
    Ok(fixtures)
}

fn scenario(random: &mut u64, sample: u32) -> Result<Value, String> {
    let count = draw(random, 7)?
        .checked_add(2)
        .ok_or("Node count overflow")?;
    let text_base = count
        .checked_mul(2)
        .and_then(|value| value.checked_add(2))
        .ok_or("Text identity overflow")?;
    let mut allocations = BTreeMap::new();
    let mut assignments = String::new();
    let declarations = {
        let mut context = NodeBuildContext {
            random,
            count,
            node_offset: 1,
            text_base,
            allocations: &mut allocations,
            source: &mut assignments,
        };
        build_nodes(&mut context)?
    };
    add_array_allocation(&mut allocations, count)?;
    let cells = reachable_cells(&allocations, &[1])?;
    let source = render_program(count, &declarations, &assignments);
    Ok(
        json!({"sample":sample,"program":source,"expectedCells":cells,"nodes":count,"arrayElements":count}),
    )
}

struct NodeBuildContext<'context> {
    random: &'context mut u64,
    count: u64,
    node_offset: u64,
    text_base: u64,
    allocations: &'context mut BTreeMap<u64, Allocation>,
    source: &'context mut String,
}

fn build_nodes(context: &mut NodeBuildContext<'_>) -> Result<Vec<String>, String> {
    let declarations = (1..=context.count)
        .map(|index| format!("node{index}"))
        .collect();
    for index in 1..=context.count {
        context
            .source
            .push_str(&format!("node{index} <- Nuevo Node();\n"));
    }
    for index in 1..=context.count {
        append_node(context, index)?;
        let array_index = index.checked_sub(1).ok_or("Array index underflow")?;
        context
            .source
            .push_str(&format!("links[{array_index}] <- node{index};\n"));
    }
    Ok(declarations)
}

fn add_array_allocation(
    allocations: &mut BTreeMap<u64, Allocation>,
    count: u64,
) -> Result<(), String> {
    let mut references = Vec::new();
    for index in 1..=count {
        references.push(index.checked_add(1).ok_or("Node identity overflow")?);
    }
    allocations.insert(
        1,
        Allocation {
            kind: AllocationKind::Array { elements: count },
            references,
        },
    );
    Ok(())
}

fn render_program(count: u64, declarations: &[String], assignments: &str) -> String {
    format!(
        "Clase Node\nPublico Definir left,right Como Node;\nPublico Definir text Como Cadena;\nFinClase\nSubProceso Build(links[] Como Node) Como Node\nDefinir {} Como Node;\n{assignments}Retornar node1;\nFinSubProceso\nAlgoritmo P\nDimension links[{count}] Como Node;\nDefinir root, extra Como Node;\nroot <- Build(links);\nextra <- Nuevo Node();\nlinks[0] <- root;\nEscribir \"ok\";\nFinAlgoritmo\n",
        declarations.join(",")
    )
}

fn append_node(context: &mut NodeBuildContext<'_>, index: u64) -> Result<(), String> {
    let mut references = build_node_references(context, index)?;
    let points = draw(context.random, 26)?;
    let object_identity = index
        .checked_add(context.node_offset)
        .ok_or("Node identity overflow")?;
    let text_identity = context
        .text_base
        .checked_add(index)
        .ok_or("Text identity overflow")?;
    append_text(context, index, text_identity, points)?;
    references.push(text_identity);
    context.allocations.insert(
        object_identity,
        Allocation {
            kind: AllocationKind::Object { fields: 3 },
            references,
        },
    );
    Ok(())
}

fn build_node_references(
    context: &mut NodeBuildContext<'_>,
    index: u64,
) -> Result<Vec<u64>, String> {
    let mut references = Vec::new();
    let limit = context.count.checked_add(1).ok_or("Node count overflow")?;
    for field in ["left", "right"] {
        let target = draw(context.random, limit)?;
        if target != 0 {
            references.push(
                target
                    .checked_add(context.node_offset)
                    .ok_or("Node identity overflow")?,
            );
            context
                .source
                .push_str(&format!("node{index}.{field} <- node{target};\n"));
        }
    }
    Ok(references)
}

fn append_text(
    context: &mut NodeBuildContext<'_>,
    index: u64,
    identity: u64,
    points: u64,
) -> Result<(), String> {
    let text = "x".repeat(usize::try_from(points).map_err(|error| error.to_string())?);
    context
        .source
        .push_str(&format!("node{index}.text <- \"\" + \"{text}\";\n"));
    context.allocations.insert(
        identity,
        Allocation {
            kind: AllocationKind::Text {
                code_points: points,
            },
            references: Vec::new(),
        },
    );
    Ok(())
}

fn draw(random: &mut u64, limit: u64) -> Result<u64, String> {
    *random = random
        .wrapping_mul(6364136223846793005)
        .wrapping_add(1442695040888963407);
    random
        .wrapping_shr(16)
        .checked_rem(limit)
        .ok_or_else(|| "Empty generator domain".to_owned())
}
