use crate::help_catalog::{
    FormLine, HelpCard, HelpCategory, HelpCommonError, HelpExample, HelpLocale, HelpPart, HelpSlot,
    cards, token_description,
};
use crate::help_resolution::{HelpIdentity, HelpIdentityKind, HelpQueryOutcome};
use pseudolearn_lexicon::Profile;

#[derive(Clone, Copy, Debug)]
pub struct HelpContent {
    pub card_id: &'static str,
    pub title: &'static str,
    pub summary: &'static str,
    pub description: Option<&'static str>,
    pub category: HelpCategory,
    pub profile: Profile,
    pub form: &'static [FormLine],
    pub parts: &'static [HelpPart],
    pub slots: &'static [HelpSlot],
    pub result: Option<&'static str>,
    pub rules: &'static [&'static str],
    pub common_errors: &'static [HelpCommonError],
    pub examples: &'static [HelpExample],
}

pub fn help_content(
    outcome: &HelpQueryOutcome,
    locale: HelpLocale,
    profile: Profile,
) -> Option<HelpContent> {
    let identity = outcome.resolution.identity.as_ref()?;
    let token = outcome.token_identity.as_deref();
    let card = select_card(identity, token)?;
    let content = card.content(locale);
    Some(HelpContent {
        card_id: card.id,
        title: content.title,
        summary: content.summary,
        description: token.and_then(|value| token_description(value, locale)),
        category: card.category,
        profile,
        form: card.form(profile),
        parts: content.parts,
        slots: content.slots,
        result: content.result,
        rules: content.rules,
        common_errors: content.common_errors,
        examples: content.examples,
    })
}

fn select_card(identity: &HelpIdentity, token: Option<&str>) -> Option<&'static HelpCard> {
    let candidates: Vec<&'static HelpCard> = cards()
        .iter()
        .filter(|card| token.is_none_or(|value| card.tokens.contains(&value)))
        .collect();
    let preferred = candidates
        .iter()
        .copied()
        .find(|card| card.identity == identity.id && card.role == identity.role)
        .or_else(|| {
            candidates
                .iter()
                .copied()
                .find(|card| fits_context(card, identity))
        });
    if matches!(
        identity.kind,
        HelpIdentityKind::Construction | HelpIdentityKind::Role
    ) {
        preferred
    } else {
        preferred.or_else(|| candidates.first().copied())
    }
}

fn fits_context(card: &HelpCard, identity: &HelpIdentity) -> bool {
    match identity.kind {
        HelpIdentityKind::Operator => fits_operator_role(card.role, &identity.role),
        HelpIdentityKind::Construction | HelpIdentityKind::Role => {
            card.identity == identity.id
                || construction_card_identity(&identity.id) == Some(card.identity)
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
        "variantConstruction" => Some("variantConstruction"),
        _ => None,
    }
}
