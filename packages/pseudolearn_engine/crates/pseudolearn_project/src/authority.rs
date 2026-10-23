use crate::manifest_error::{ManifestError, ManifestErrorCode};
use crate::manifest_model::{LimitName, LimitRequest, Provenance};
use std::collections::BTreeMap;

#[derive(Clone, Debug, Default, Eq, PartialEq)]
pub struct HostGrants {
    pub limits: BTreeMap<LimitName, u64>,
}

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub struct LimitAuthority {
    pub requested: u64,
    pub granted: Option<u64>,
    pub effective: Option<u64>,
    pub provenance: Provenance,
}

pub(crate) fn resolve_limits(
    requests: &BTreeMap<LimitName, LimitRequest>,
    grants: &HostGrants,
) -> (BTreeMap<LimitName, LimitAuthority>, Vec<ManifestError>) {
    let mut authorities = BTreeMap::new();
    let mut errors = Vec::new();
    for (name, request) in requests {
        let granted = grants.limits.get(name).copied();
        authorities.insert(*name, authority(request, granted));
        if granted.is_none() {
            errors.push(ManifestError::new(
                ManifestErrorCode::LimitNotGranted,
                &format!("requests.limits.{}", name.as_str()),
                request.position,
            ));
        }
    }
    (authorities, errors)
}

fn authority(request: &LimitRequest, granted: Option<u64>) -> LimitAuthority {
    let Some(ceiling) = granted else {
        return LimitAuthority {
            requested: request.requested,
            granted,
            effective: None,
            provenance: Provenance::Manifest(request.position),
        };
    };
    let within = request.requested <= ceiling;
    LimitAuthority {
        requested: request.requested,
        granted,
        effective: Some(request.requested.min(ceiling)),
        provenance: if within {
            Provenance::Manifest(request.position)
        } else {
            Provenance::Host
        },
    }
}
