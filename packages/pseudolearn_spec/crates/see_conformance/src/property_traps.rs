use crate::{properties::PropertySubject, property_scenarios::Scenario};
use see_model::properties::PropertyExecutor;
use serde_json::{Value, json};

type Difference = Result<Option<(Value, Value)>, String>;

const EDGES: [i64; 8] = [
    i64::MAX,
    -9_223_372_036_854_775_807,
    4_611_686_018_427_387_904,
    3_037_000_500,
    2,
    1,
    0,
    7,
];
const OPERATORS: [&str; 3] = ["+", "-", "*"];
const EXPRESSION_COLUMN: usize = 6;

struct Chain {
    operator: &'static str,
    operands: Vec<i64>,
}

pub(crate) fn check(
    executor: PropertyExecutor,
    scenario: &Scenario,
    subject: &mut impl PropertySubject,
) -> Difference {
    let seed = scenario
        .request
        .get("seed")
        .and_then(Value::as_u64)
        .unwrap_or_default()
        .wrapping_add(program_weight(&scenario.request));
    let chain = generate(seed)?;
    let through_variables = executor == PropertyExecutor::FusedFirstTrap;
    let program = render(&chain, through_variables);
    let expected = expectation(&chain, through_variables);
    for observe in ["none", "events"] {
        let response = subject.exchange(&json!({"kind":"execute","program":program,
            "profile":"es","strictness":"strict","inputs":[],"seed":0,"observe":observe,
            "limits":{"micro_steps":100_000}}))?;
        let actual = observable(&response);
        if actual != expected {
            return Ok(Some((expected, actual)));
        }
    }
    Ok(None)
}

fn program_weight(request: &Value) -> u64 {
    let length = request
        .get("program")
        .and_then(Value::as_str)
        .map_or(0, str::len);
    u64::try_from(length).unwrap_or_default()
}

struct Generator {
    state: u64,
}

impl Generator {
    fn next(&mut self) -> usize {
        self.state = self
            .state
            .wrapping_mul(6_364_136_223_846_793_005)
            .wrapping_add(1_442_695_040_888_963_407);
        usize::try_from(self.state >> 33).unwrap_or_default()
    }

    fn pick<Choice: Copy>(&mut self, items: &[Choice]) -> Result<Choice, String> {
        let position = self
            .next()
            .checked_rem(items.len())
            .ok_or("SEE-PROPERTY: empty choice")?;
        items
            .get(position)
            .copied()
            .ok_or("SEE-PROPERTY: choice out of range".to_owned())
    }
}

fn generate(seed: u64) -> Result<Chain, String> {
    let mut generator = Generator {
        state: seed.wrapping_mul(2_862_933_555_777_941_757).wrapping_add(3),
    };
    let operator = generator.pick(&OPERATORS)?;
    let extra = generator.pick(&[0_usize, 1, 2, 3])?;
    let mut operands = Vec::new();
    for _ in 0..extra.saturating_add(2) {
        operands.push(generator.pick(&EDGES)?);
    }
    Ok(Chain { operator, operands })
}

fn render(chain: &Chain, through_variables: bool) -> String {
    let mut lines = vec!["Algoritmo P".to_owned()];
    let mut terms = Vec::new();
    for (index, operand) in chain.operands.iter().enumerate() {
        if through_variables {
            lines.push(format!("Definir v{index} Como Entero;"));
            lines.push(format!("v{index} <- {operand};"));
            terms.push(format!("v{index}"));
        } else {
            terms.push(operand.to_string());
        }
    }
    lines.push("Definir r Como Entero;".to_owned());
    lines.push(format!(
        "r <- {};",
        terms.join(&format!(" {} ", chain.operator))
    ));
    lines.push("Escribir r;".to_owned());
    lines.push("FinAlgoritmo".to_owned());
    format!("{}\n", lines.join("\n"))
}

fn apply(operator: &str, accumulator: i64, operand: i64) -> Option<i64> {
    match operator {
        "+" => accumulator.checked_add(operand),
        "-" => accumulator.checked_sub(operand),
        _ => accumulator.checked_mul(operand),
    }
}

fn expectation(chain: &Chain, through_variables: bool) -> Value {
    let Some(mut accumulator) = chain.operands.first().copied() else {
        return json!({});
    };
    let line = if through_variables {
        chain.operands.len().saturating_mul(2).saturating_add(3)
    } else {
        3
    };
    let mut column = EXPRESSION_COLUMN.saturating_add(width(chain, 0, through_variables));
    for (index, operand) in chain.operands.iter().enumerate().skip(1) {
        let operator_column = column.saturating_add(1);
        let Some(result) = apply(chain.operator, accumulator, *operand) else {
            return json!({"termination":{"code":"integerOverflow","kind":"failed"},
                "output":"","line":line,"column":operator_column});
        };
        accumulator = result;
        column = column
            .saturating_add(3)
            .saturating_add(width(chain, index, through_variables));
    }
    json!({"termination":{"kind":"completed"},"output":format!("{accumulator}\n")})
}

fn width(chain: &Chain, index: usize, through_variables: bool) -> usize {
    if through_variables {
        index.to_string().len().saturating_add(1)
    } else {
        chain
            .operands
            .get(index)
            .map_or(0, |value| value.to_string().len())
    }
}

fn observable(response: &Value) -> Value {
    let output = response.get("output").cloned().unwrap_or(Value::Null);
    let termination = response.get("termination").cloned().unwrap_or(Value::Null);
    if response.pointer("/termination/kind") == Some(&json!("completed")) {
        return json!({"termination":{"kind":"completed"},"output":output});
    }
    let start = response.pointer("/diagnostics/0/span/start");
    json!({"termination":termination,"output":output,
        "line":start.and_then(|position| position.get("line")),
        "column":start.and_then(|position| position.get("column"))})
}
