use crate::help_catalog::{HelpCard, HelpExample, HelpLocale, HelpPart, cards, token_description};
use crate::help_resolution::{HelpIdentity, HelpIdentityKind, HelpQueryOutcome};

#[derive(Clone, Copy, Debug)]
pub struct HelpContent {
    pub card_id: &'static str,
    pub title: &'static str,
    pub summary: &'static str,
    pub purpose: &'static str,
    pub description: Option<&'static str>,
    pub parts: &'static [HelpPart],
    pub constraints: &'static [&'static str],
    pub common_errors: &'static [&'static str],
    pub examples: &'static [HelpExample],
}

pub fn help_content(outcome: &HelpQueryOutcome, locale: HelpLocale) -> Option<HelpContent> {
    let identity = outcome.resolution.identity.as_ref()?;
    let token = outcome.token_identity.as_deref()?;
    let card = select_card(identity, token)?;
    let content = card.content(locale);
    Some(HelpContent {
        card_id: card.id,
        title: content.title,
        summary: content.summary,
        purpose: content.purpose,
        description: token_description(token, locale),
        parts: content.parts,
        constraints: content.constraints,
        common_errors: content.common_errors,
        examples: content.examples,
    })
}

fn select_card(identity: &HelpIdentity, token: &str) -> Option<&'static HelpCard> {
    let candidates: Vec<&'static HelpCard> = cards()
        .iter()
        .filter(|card| card.tokens.contains(&token))
        .collect();
    let preferred = candidates
        .iter()
        .copied()
        .find(|card| fits_context(card, identity));
    preferred.or_else(|| candidates.first().copied())
}

fn fits_context(card: &HelpCard, identity: &HelpIdentity) -> bool {
    match identity.kind {
        HelpIdentityKind::Operator => fits_operator_role(card.role, &identity.role),
        HelpIdentityKind::Construction | HelpIdentityKind::Role => {
            construction_card_identity(&identity.id) == Some(card.identity)
        }
        _ => false,
    }
}

fn fits_operator_role(card_role: &str, resolved_role: &str) -> bool {
    match resolved_role {
        "unary" => card_role == "unary_sign_or_negation",
        "binary" => card_role != "unary_sign_or_negation",
        _ => false,
    }
}

fn construction_card_identity(resolved: &str) -> Option<&'static str> {
    match resolved {
        "algorithm" => Some("algorithm"),
        "for" => Some("forLoop"),
        "while" => Some("whileLoop"),
        "switch" => Some("switch"),
        "repeat" => Some("repeatLoop"),
        "parameter" => Some("parameter"),
        _ => None,
    }
}
