#[derive(Clone, Debug, Default, Eq, PartialEq)]
pub struct ProcessOptions {
    pub effects_in: Option<String>,
    pub effects_out: Option<String>,
    pub seed: Option<i64>,
    pub program_arguments: Vec<String>,
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub enum ProcessOptionsError {
    MissingValue(String),
    InvalidSeed(String),
}

const SEED_FLAGS: &[&str] = &["--semilla", "--seed"];
const EFFECTS_IN_FLAG: &str = "--effects-in";
const EFFECTS_OUT_FLAG: &str = "--effects-out";

impl ProcessOptions {
    pub fn parse(arguments: &[String]) -> Result<Self, ProcessOptionsError> {
        let mut options = Self::default();
        let mut remaining = arguments.iter();
        while let Some(argument) = remaining.next() {
            let flag = argument.as_str();
            if flag == "--" {
                options.program_arguments.extend(remaining.cloned());
                break;
            }
            if !is_runtime_flag(flag) {
                options.program_arguments.push(argument.clone());
                options.program_arguments.extend(remaining.cloned());
                break;
            }
            let value = remaining
                .next()
                .ok_or_else(|| ProcessOptionsError::MissingValue(flag.to_owned()))?;
            options.assign(flag, value)?;
        }
        Ok(options)
    }

    fn assign(&mut self, flag: &str, value: &str) -> Result<(), ProcessOptionsError> {
        match flag {
            EFFECTS_IN_FLAG => self.effects_in = Some(value.to_owned()),
            EFFECTS_OUT_FLAG => self.effects_out = Some(value.to_owned()),
            _ => {
                let seed = value
                    .parse::<i64>()
                    .map_err(|_| ProcessOptionsError::InvalidSeed(value.to_owned()))?;
                self.seed = Some(seed);
            }
        }
        Ok(())
    }
}

fn is_runtime_flag(flag: &str) -> bool {
    flag == EFFECTS_IN_FLAG || flag == EFFECTS_OUT_FLAG || SEED_FLAGS.contains(&flag)
}
