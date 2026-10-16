#![forbid(unsafe_code)]

use crate::events::TraceEvent;

const WIRE_SIGNATURE: &[u8; 4] = b"PLEV";
const WIRE_VERSION: u16 = 1;
const WIRE_RESERVED: u16 = 0;

pub fn encode_plev(events: &[TraceEvent]) -> Vec<u8> {
    let count = events.len();
    let mut pool = String::new();
    let mut offsets = Vec::with_capacity(count);

    for event in events {
        let current_offset = u32::try_from(pool.len()).unwrap_or(u32::MAX);
        offsets.push(current_offset);
        if let Some(payload) = &event.payload {
            pool.push_str(&payload.to_canonical_json());
        }
    }

    let mut result = Vec::new();
    write_header(count, &mut result);
    write_columns(events, &offsets, &mut result);
    write_pool(&pool, &mut result);
    result
}

fn write_header(count: usize, output: &mut Vec<u8>) {
    output.extend_from_slice(WIRE_SIGNATURE);
    output.extend_from_slice(&WIRE_VERSION.to_le_bytes());
    output.extend_from_slice(&WIRE_RESERVED.to_le_bytes());
    let count_u64 = u64::try_from(count).unwrap_or(0);
    output.extend_from_slice(&count_u64.to_le_bytes());
}

fn write_columns(events: &[TraceEvent], offsets: &[u32], output: &mut Vec<u8>) {
    for event in events {
        output.push(event.class.to_u8());
    }
    for event in events {
        output.extend_from_slice(&event.line.to_le_bytes());
    }
    for event in events {
        output.extend_from_slice(&event.depth.to_le_bytes());
    }
    for offset in offsets {
        output.extend_from_slice(&offset.to_le_bytes());
    }
}

fn write_pool(pool: &str, output: &mut Vec<u8>) {
    let pool_length = u32::try_from(pool.len()).unwrap_or(0);
    output.extend_from_slice(&pool_length.to_le_bytes());
    output.extend_from_slice(pool.as_bytes());
}
