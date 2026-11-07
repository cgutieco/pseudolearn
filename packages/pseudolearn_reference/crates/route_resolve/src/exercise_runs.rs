use crate::RouteContext;
use crate::laps::{instrument, observed_rows};
use reference_model::{
    CaseSource, ExecutionReport, ExecutionRequest, LapCheck, LapTable, Profile, ProgramSource,
    PublishedCase, RoleRuns, RunRecord,
};
use reference_resolve::{target_code, with_final_newline};

pub const EXERCISE_STATEMENT_LIMIT: u64 = 100_000;
pub const EXERCISE_DEPTH_LIMIT: usize = 1_000;

#[derive(Clone, Debug, Default)]
pub struct CaseSets<'sets> {
    pub cases: &'sets [CaseSource],
    pub breakers: &'sets [CaseSource],
    pub solution: &'sets [CaseSource],
}

pub fn execute(
    context: &RouteContext<'_>,
    program: &ProgramSource,
    inputs: &[String],
    profile: Profile,
) -> ExecutionReport {
    let spanish = with_final_newline(&program.code);
    let code = match profile {
        Profile::Spanish => spanish,
        Profile::English => target_code(context.resolution, &spanish),
    };
    run_code(context, program, (code, profile), inputs)
}

fn run_code(
    context: &RouteContext<'_>,
    program: &ProgramSource,
    (code, profile): (String, Profile),
    inputs: &[String],
) -> ExecutionReport {
    context.resolution.engine.execute(&ExecutionRequest {
        code,
        profile,
        inputs: inputs.to_vec(),
        host: program.host.clone(),
        trace: false,
        statement_limit: program.statement_limit.or(Some(EXERCISE_STATEMENT_LIMIT)),
        depth_limit: Some(EXERCISE_DEPTH_LIMIT),
    })
}

pub fn role_runs(
    context: &RouteContext<'_>,
    program: &ProgramSource,
    sets: &CaseSets<'_>,
) -> RoleRuns {
    let records = |cases: &[CaseSource]| -> Vec<RunRecord> {
        cases
            .iter()
            .map(|case| {
                record(
                    execute(context, program, &case.inputs, Profile::Spanish),
                    case,
                )
            })
            .collect()
    };
    RoleRuns {
        role: program.role.clone().unwrap_or_default(),
        id: program.id.clone(),
        cases: records(sets.cases),
        breakers: records(sets.breakers),
        solution: records(sets.solution),
    }
}

fn record(report: ExecutionReport, case: &CaseSource) -> RunRecord {
    RunRecord {
        inputs: case.inputs.clone(),
        expected: case.expected.clone(),
        hidden: case.hidden,
        output: report.output,
        termination: report.termination,
    }
}

pub fn published_cases(
    context: &RouteContext<'_>,
    reference: &ProgramSource,
    cases: &[CaseSource],
) -> Vec<PublishedCase> {
    cases
        .iter()
        .map(|case| PublishedCase {
            inputs: case.inputs.clone(),
            expected: execute(context, reference, &case.inputs, context.resolution.profile)
                .output
                .trim_end_matches('\n')
                .to_owned(),
            hidden: case.hidden,
        })
        .collect()
}

pub fn lap_check(
    context: &RouteContext<'_>,
    program: &ProgramSource,
    table: &LapTable,
    profile: Profile,
) -> LapCheck {
    let mut instrumented = program.clone();
    instrumented.code = instrument(&with_final_newline(&program.code), table);
    let report = execute(context, &instrumented, &program.inputs, profile);
    LapCheck {
        expected: table.rows.clone(),
        observed: observed_rows(&report.output),
        termination: report.termination,
    }
}
