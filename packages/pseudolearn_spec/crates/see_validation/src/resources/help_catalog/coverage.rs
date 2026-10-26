use super::CoverageRow;
#[path = "coverage_inventory.rs"]
mod catalog_inventory;
#[path = "coverage_presentation.rs"]
mod catalog_presentation;
use self::catalog_inventory::{
    alphabetic_lexeme, array, grammar_operators, identity_key, operator_inventory, role_inventory,
    source_resource, string_set, token_category,
};
use self::catalog_presentation::{
    card_content_covers, card_token_set, check_productions, complete_scope, coverage_destination,
    coverage_row, row_order,
};
use see_model::Corpus;
use serde_json::{Map, Value};
use std::collections::BTreeSet;

struct InventorySources<'source> {
    vocabulary: &'source Map<String, Value>,
    functions: &'source Map<String, Value>,
    productions: &'source Map<String, Value>,
    operators: BTreeSet<String>,
}

struct CoverageMatrix<'catalog, 'source> {
    catalog: &'catalog Value,
    sources: InventorySources<'source>,
    rows: Vec<CoverageRow>,
    roles: BTreeSet<(String, String, String)>,
    tokens: BTreeSet<String>,
}

pub(super) fn matrix(value: &Value, corpus: &Corpus) -> Result<Vec<CoverageRow>, String> {
    let mut vocabulary = source_resource(corpus, "LANG.PROFILE.VOCABULARY", "vocabulary")?.clone();
    vocabulary.extend(
        source_resource(corpus, "LANG.PROFILE.VOCABULARY", "contextualVocabulary")?.clone(),
    );
    let functions = source_resource(corpus, "LIB.MODEL", "functions")?;
    let grammar = source_resource(corpus, "LANG.SYNTAX.GRAMMAR", "grammar")?;
    let productions = grammar
        .get("producciones")
        .and_then(Value::as_object)
        .ok_or("missing grammar productions")?;
    let operators = operator_inventory(value)?;
    if operators != grammar_operators(productions, &vocabulary) {
        return Err("operator inventory differs from grammar".to_owned());
    }
    let sources = InventorySources {
        vocabulary: &vocabulary,
        functions,
        productions,
        operators,
    };
    CoverageMatrix::new(value, sources).collect()
}

impl<'catalog, 'source> CoverageMatrix<'catalog, 'source> {
    fn new(catalog: &'catalog Value, sources: InventorySources<'source>) -> Self {
        Self {
            catalog,
            sources,
            rows: Vec::new(),
            roles: BTreeSet::new(),
            tokens: BTreeSet::new(),
        }
    }

    fn collect(mut self) -> Result<Vec<CoverageRow>, String> {
        for role in role_inventory(self.catalog)?.clone() {
            self.collect_role(&role)?;
        }
        self.append_missing_tokens();
        self.reject_unlisted_items()?;
        self.rows.sort_by(row_order);
        Ok(self.rows)
    }

    fn collect_role(&mut self, role: &Value) -> Result<(), String> {
        let identity = role.get("identity").ok_or("missing role identity")?;
        let identity_key = identity_key(identity)?;
        if !self.roles.insert(identity_key.clone()) {
            return Err("duplicate inventory role identity".to_owned());
        }
        check_productions(role, self.sources.productions)?;
        let tokens = string_set(role, "tokens")?;
        let destination = self.destination(identity, &tokens);
        self.rows.push(coverage_row(
            "role",
            &identity_key.1,
            &identity_key.2,
            &destination,
        ));
        self.collect_role_tokens(&tokens, &identity_key.2, destination)
    }

    fn collect_role_tokens(
        &mut self,
        tokens: &BTreeSet<String>,
        role: &str,
        destination: Option<String>,
    ) -> Result<(), String> {
        for token in tokens {
            let category = token_category(
                token,
                self.sources.vocabulary,
                self.sources.functions,
                &self.sources.operators,
            )?;
            if destination.is_some() {
                self.tokens.insert(token.clone());
            }
            self.rows
                .push(coverage_row(category, token, role, &destination));
        }
        Ok(())
    }

    fn destination(&self, identity: &Value, tokens: &BTreeSet<String>) -> Option<String> {
        if let Some(card) = self.matching_record("/cards", identity)
            && complete_scope(card)
            && self.card_matches_role(card, identity, tokens).ok()?
        {
            return coverage_destination(card, "card");
        }
        self.matching_record("/exclusions", identity)
            .filter(|exclusion| complete_scope(exclusion))
            .and_then(|exclusion| coverage_destination(exclusion, "exclusion"))
    }

    fn matching_record(&self, catalog_path: &str, identity: &Value) -> Option<&Value> {
        array(self.catalog, catalog_path)
            .ok()?
            .iter()
            .find(|record| record.get("identity") == Some(identity))
    }

    fn card_matches_role(
        &self,
        card: &Value,
        identity: &Value,
        tokens: &BTreeSet<String>,
    ) -> Result<bool, String> {
        if card_token_set(card)? != *tokens {
            return Ok(false);
        }
        let role = role_inventory(self.catalog)?
            .iter()
            .find(|entry| entry.get("identity") == Some(identity))
            .ok_or("missing declared inventory role")?;
        if string_set(role, "tokens")? != *tokens {
            return Ok(false);
        }
        card_content_covers(card, tokens, &self.sources)
    }

    fn append_missing_tokens(&mut self) {
        for identity in self
            .sources
            .vocabulary
            .keys()
            .chain(self.sources.functions.keys())
        {
            let category = self.token_category(identity);
            if let Some(category) = category
                && !self.tokens.contains(identity)
            {
                self.rows
                    .push(coverage_row(category, identity, "unassigned", &None));
            }
        }
    }

    fn token_category(&self, identity: &str) -> Option<&'static str> {
        if self.sources.operators.contains(identity) {
            Some("operator")
        } else if self.sources.functions.contains_key(identity) {
            Some("builtin")
        } else if self
            .sources
            .vocabulary
            .get(identity)
            .is_some_and(alphabetic_lexeme)
        {
            Some("keyword")
        } else {
            None
        }
    }

    fn reject_unlisted_items(&self) -> Result<(), String> {
        for card in array(self.catalog, "/cards")? {
            let identity = card.get("identity").ok_or("missing card identity")?;
            if !self.roles.contains(&identity_key(identity)?) {
                return Err("card has no declared inventory role".to_owned());
            }
            let tokens = role_inventory(self.catalog)?
                .iter()
                .find(|role| role.get("identity") == Some(identity))
                .ok_or("missing declared inventory role")?;
            if card_token_set(card)? != string_set(tokens, "tokens")? {
                return Err("card tokens differ from its declared inventory role".to_owned());
            }
        }
        for exclusion in array(self.catalog, "/exclusions")? {
            let identity = exclusion
                .get("identity")
                .ok_or("missing exclusion identity")?;
            if !self.roles.contains(&identity_key(identity)?) {
                return Err("exclusion has no declared inventory role".to_owned());
            }
        }
        Ok(())
    }
}
