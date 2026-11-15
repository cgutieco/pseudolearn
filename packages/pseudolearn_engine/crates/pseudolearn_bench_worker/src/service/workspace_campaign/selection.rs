use crate::service::workspace_campaign::loads::{LOADS, Load};
use crate::service::workspace_campaign::scenario::Scenario;
use std::collections::BTreeSet;

#[derive(Clone, Debug, Default)]
pub struct Selection {
    loads: Option<BTreeSet<String>>,
    scenarios: Option<BTreeSet<Scenario>>,
    explicit: bool,
}

impl Selection {
    pub fn parse(arguments: &[String]) -> Result<Self, String> {
        let mut selection = Self::default();
        let mut position = 0usize;
        while let Some(option) = arguments.get(position) {
            let value = arguments
                .get(position.saturating_add(1))
                .ok_or_else(|| format!("missing value for {option}"))?;
            selection.explicit = true;
            match option.as_str() {
                "--load" => selection.add_load(value)?,
                "--scenario" => selection.add_scenario(value)?,
                _ => return Err(format!("unknown option {option}")),
            }
            position = position.saturating_add(2);
        }
        Ok(selection)
    }

    fn add_load(&mut self, name: &str) -> Result<(), String> {
        if !LOADS.iter().any(|load| load.name == name) {
            return Err(format!("unknown load {name}"));
        }
        self.loads
            .get_or_insert_with(BTreeSet::new)
            .insert(name.to_owned());
        Ok(())
    }

    fn add_scenario(&mut self, name: &str) -> Result<(), String> {
        let scenario = Scenario::SAMPLED
            .iter()
            .find(|scenario| scenario.name() == name)
            .copied()
            .ok_or_else(|| format!("unknown sampled scenario {name}"))?;
        self.scenarios
            .get_or_insert_with(BTreeSet::new)
            .insert(scenario);
        Ok(())
    }

    pub fn includes(&self, load: &str, scenario: Scenario) -> bool {
        self.loads.as_ref().is_none_or(|loads| loads.contains(load))
            && self
                .scenarios
                .as_ref()
                .is_none_or(|scenarios| scenarios.contains(&scenario))
    }

    pub fn expected_groups(&self) -> Vec<(&'static Load, Scenario)> {
        LOADS
            .iter()
            .filter(|load| {
                self.loads
                    .as_ref()
                    .is_none_or(|names| names.contains(load.name))
            })
            .flat_map(|load| {
                Scenario::SAMPLED
                    .iter()
                    .filter(|scenario| {
                        self.scenarios
                            .as_ref()
                            .is_none_or(|scenarios| scenarios.contains(scenario))
                    })
                    .map(move |scenario| (load, *scenario))
            })
            .collect()
    }

    pub fn includes_load(&self, load: &str) -> bool {
        self.loads.as_ref().is_none_or(|loads| loads.contains(load))
    }

    pub fn is_partial(&self) -> bool {
        self.explicit
    }
}
