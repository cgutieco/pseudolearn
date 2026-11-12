use pseudolearn_abi::ChannelLayout;

#[test]
fn channel_layout_rejects_zero_capacity_and_preserves_minimum_element_cost() {
    assert_eq!(ChannelLayout::new(0, 1), None);
    assert_eq!(
        ChannelLayout::new(1, 0).and_then(ChannelLayout::cells),
        Some(2)
    );
    assert_eq!(
        ChannelLayout::new(65_536, 2).and_then(ChannelLayout::cells),
        Some(131_073)
    );
}
