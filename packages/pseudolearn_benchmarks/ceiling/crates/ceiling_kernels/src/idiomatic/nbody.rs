use std::f64::consts::PI;

const SOLAR_MASS: f64 = 4.0 * PI * PI;
const DAYS_PER_YEAR: f64 = 365.24;
const STEP: f64 = 0.01;

#[derive(Clone, Copy)]
pub struct Body {
    pub position: [f64; 3],
    pub velocity: [f64; 3],
    pub mass: f64,
}

pub const PLANETS: [[f64; 7]; 4] = [
    [
        4.841431442464721,
        -1.1603200440274284,
        -0.10362204447112311,
        0.001660076642744037,
        0.007699011184197404,
        -6.90460016972063e-05,
        0.0009547919384243266,
    ],
    [
        8.34336671824458,
        4.124798564124305,
        -0.4035234171143214,
        -0.002767425107268624,
        0.004998528012349172,
        2.3041729757376393e-05,
        0.0002858859806661308,
    ],
    [
        12.894369562139131,
        -15.111151401698631,
        -0.22330757889265573,
        0.002964601375647616,
        0.0023784717395948095,
        -2.9658956854023756e-05,
        4.366244043351563e-05,
    ],
    [
        15.379697114850917,
        -25.919314609987964,
        0.17925877295037118,
        0.0026806777249038932,
        0.001628241700382423,
        -9.515922545197159e-05,
        5.1513890204661145e-05,
    ],
];

pub fn system() -> Vec<Body> {
    let mut bodies = vec![Body {
        position: [0.0; 3],
        velocity: [0.0; 3],
        mass: SOLAR_MASS,
    }];
    for [horizontal, vertical, depth, speed_x, speed_y, speed_z, mass] in PLANETS {
        bodies.push(Body {
            position: [horizontal, vertical, depth],
            velocity: [
                speed_x * DAYS_PER_YEAR,
                speed_y * DAYS_PER_YEAR,
                speed_z * DAYS_PER_YEAR,
            ],
            mass: mass * SOLAR_MASS,
        });
    }
    let mut momentum = [0.0_f64; 3];
    for body in &bodies {
        for (total, speed) in momentum.iter_mut().zip(body.velocity) {
            *total += speed * body.mass;
        }
    }
    if let Some(sun) = bodies.first_mut() {
        for (speed, total) in sun.velocity.iter_mut().zip(momentum) {
            *speed = 0.0 - total / SOLAR_MASS;
        }
    }
    bodies
}

fn interact(first: &mut Body, second: &mut Body) {
    let delta: [f64; 3] = std::array::from_fn(|axis| {
        first.position.get(axis).copied().unwrap_or_default()
            - second.position.get(axis).copied().unwrap_or_default()
    });
    let [delta_x, delta_y, delta_z] = delta;
    let squared = delta_x * delta_x + delta_y * delta_y + delta_z * delta_z;
    let magnitude = STEP / (squared * squared.sqrt());
    for ((speed, other), difference) in first
        .velocity
        .iter_mut()
        .zip(second.velocity.iter_mut())
        .zip(delta)
    {
        *speed -= difference * second.mass * magnitude;
        *other += difference * first.mass * magnitude;
    }
}

fn advance(bodies: &mut [Body]) {
    for split in 1..bodies.len() {
        let (left, right) = bodies.split_at_mut(split);
        if let Some(first) = left.last_mut() {
            for second in right.iter_mut() {
                interact(first, second);
            }
        }
    }
    for body in bodies.iter_mut() {
        for (position, speed) in body.position.iter_mut().zip(body.velocity) {
            *position += STEP * speed;
        }
    }
}

fn energy(bodies: &[Body]) -> f64 {
    let mut total = 0.0_f64;
    for (index, first) in bodies.iter().enumerate() {
        let [speed_x, speed_y, speed_z] = first.velocity;
        total += 0.5 * first.mass * (speed_x * speed_x + speed_y * speed_y + speed_z * speed_z);
        for second in bodies.iter().skip(index.wrapping_add(1)) {
            let [delta_x, delta_y, delta_z]: [f64; 3] = std::array::from_fn(|axis| {
                first.position.get(axis).copied().unwrap_or_default()
                    - second.position.get(axis).copied().unwrap_or_default()
            });
            total -= first.mass * second.mass
                / (delta_x * delta_x + delta_y * delta_y + delta_z * delta_z).sqrt();
        }
    }
    total
}

pub fn run(size: usize) -> String {
    let mut bodies = system();
    for _ in 0..size {
        advance(&mut bodies);
    }
    format!("{:.0}", (energy(&bodies) * 1_000_000_000_000_000.0).trunc())
}
