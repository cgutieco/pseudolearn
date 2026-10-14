fn escapes(real: f64, imaginary: f64) -> u32 {
    let (mut squared_real, mut current_imaginary, mut squared_imaginary) =
        (0.0_f64, 0.0_f64, 0.0_f64);
    for _ in 0..50 {
        let current_real = squared_real - squared_imaginary + real;
        current_imaginary = 2.0 * current_real * current_imaginary + imaginary;
        squared_real = current_real * current_real;
        squared_imaginary = current_imaginary * current_imaginary;
        if squared_real + squared_imaginary > 4.0 {
            return 1;
        }
    }
    0
}

fn coordinate(position: u32, size: u32, offset: f64) -> f64 {
    2.0 * f64::from(position) / f64::from(size) - offset
}

pub fn run(size: usize) -> String {
    let side = u32::try_from(size).unwrap_or_default();
    let (mut sum, mut accumulated, mut bits) = (0_u32, 0_u32, 0_u32);
    for row in 0..side {
        let imaginary = coordinate(row, side, 1.0);
        for column in 0..side {
            let real = coordinate(column, side, 1.5);
            accumulated = accumulated
                .wrapping_shl(1)
                .wrapping_add(escapes(real, imaginary));
            bits = bits.wrapping_add(1);
            if bits == 8 || column == side.wrapping_sub(1) {
                accumulated = accumulated.wrapping_shl(8_u32.wrapping_sub(bits));
                sum ^= accumulated;
                (accumulated, bits) = (0, 0);
            }
        }
    }
    sum.to_string()
}
