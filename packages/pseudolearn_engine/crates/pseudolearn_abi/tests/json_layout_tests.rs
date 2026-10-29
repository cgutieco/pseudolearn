use pseudolearn_abi::json_layout::{
    JSON_BLOCK_HEADER_WORDS, JSON_BLOCK_NODE_COUNT_WORD_OFFSET, JSON_BLOCK_SHAPE_TAG,
    JSON_BLOCK_TEXT_LENGTH_WORD_OFFSET, JSON_NODE_NAME_LENGTH_WORD_OFFSET,
    JSON_NODE_NAME_OFFSET_WORD_OFFSET, JSON_NODE_VALUE_LENGTH_WORD_OFFSET,
    JSON_NODE_VALUE_OFFSET_WORD_OFFSET, JSON_NODE_WORD_OFFSETS, JSON_NODE_WORDS,
    JSON_VIEW_BLOCK_WORD_OFFSET, JSON_VIEW_NODE_WORD_OFFSET, JSON_VIEW_SHAPE_TAG, JsonNodeKind,
};

#[test]
fn assigns_stable_json_kind_tags() {
    assert_eq!(JsonNodeKind::Null.tag(), 0);
    assert_eq!(JsonNodeKind::Boolean.tag(), 1);
    assert_eq!(JsonNodeKind::Number.tag(), 2);
    assert_eq!(JsonNodeKind::String.tag(), 3);
    assert_eq!(JsonNodeKind::Array.tag(), 4);
    assert_eq!(JsonNodeKind::Object.tag(), 5);
}

#[test]
fn reserves_distinct_heap_shapes_for_json_blocks_and_views() {
    assert_eq!(JSON_BLOCK_SHAPE_TAG, u32::MAX - 5);
    assert_eq!(JSON_VIEW_SHAPE_TAG, u32::MAX - 4);
    assert_eq!(JSON_NODE_WORDS, 8);
    assert_eq!(JSON_BLOCK_HEADER_WORDS, 2);
    assert_eq!(JSON_BLOCK_NODE_COUNT_WORD_OFFSET, 2);
    assert_eq!(JSON_BLOCK_TEXT_LENGTH_WORD_OFFSET, 3);
    assert_eq!(JSON_VIEW_BLOCK_WORD_OFFSET, 2);
    assert_eq!(JSON_VIEW_NODE_WORD_OFFSET, 3);
    assert_eq!(JSON_NODE_WORD_OFFSETS, [0, 1, 2, 3, 4, 5, 6, 7]);
    assert_eq!(JSON_NODE_NAME_OFFSET_WORD_OFFSET, 4);
    assert_eq!(JSON_NODE_NAME_LENGTH_WORD_OFFSET, 5);
    assert_eq!(JSON_NODE_VALUE_OFFSET_WORD_OFFSET, 6);
    assert_eq!(JSON_NODE_VALUE_LENGTH_WORD_OFFSET, 7);
}
