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
    let mut allocations = BTreeMap::new();
    let mut declarations = Vec::new();
    let mut assignments = String::new();
    for index in 1..=count {
        declarations.push(format!("node{index}"));
        assignments.push_str(&format!("node{index} <- Nuevo Node();\n"));
    }
    for index in 1..=count {
        append_node(random, (index, count), &mut allocations, &mut assignments)?;
    }
    let cells = reachable_cells(&allocations, &[1])?;
    let source = format!(
        "Clase Node\nPublico Definir left,right Como Node;\nPublico Definir text Como Cadena;\nFinClase\nSubProceso Build() Como Node\nDefinir {} Como Node;\n{assignments}Retornar node1;\nFinSubProceso\nAlgoritmo P\nDefinir root, extra Como Node;\nroot <- Build();\nextra <- Nuevo Node();\nEscribir \"ok\";\nFinAlgoritmo\n",
        declarations.join(",")
    );
    Ok(json!({"sample":sample,"program":source,"expectedCells":cells,"nodes":count}))
}

fn append_node(
    random: &mut u64,
    (index, count): (u64, u64),
    allocations: &mut BTreeMap<u64, Allocation>,
    source: &mut String,
) -> Result<(), String> {
    let mut references = Vec::new();
    for field in ["left", "right"] {
        let target = draw(random, count.checked_add(1).ok_or("Node count overflow")?)?;
        if target != 0 {
            references.push(target);
            source.push_str(&format!("node{index}.{field} <- node{target};\n"));
        }
    }
    let points = draw(random, 26)?;
    let identity = count.checked_add(index).ok_or("Text identity overflow")?;
    let text = "x".repeat(usize::try_from(points).map_err(|error| error.to_string())?);
    source.push_str(&format!("node{index}.text <- \"\" + \"{text}\";\n"));
    references.push(identity);
    allocations.insert(
        identity,
        Allocation {
            kind: AllocationKind::Text {
                code_points: points,
            },
            references: Vec::new(),
        },
    );
    allocations.insert(
        index,
        Allocation {
            kind: AllocationKind::Object { fields: 3 },
            references,
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
