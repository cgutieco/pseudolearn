use crate::machine::{Handle, Machine, Outcome, Shape};

const DISK: Shape = Shape { links: 1, words: 1 };
const NEXT: u8 = 0;
const SIZE: u8 = 1;

struct Towers {
    piles: Handle,
    moves: i64,
}

fn disk<Implementation: Machine>(machine: &mut Implementation, size: i64) -> Outcome<Handle> {
    let disk = machine.object(DISK)?;
    machine.set_field(disk, SIZE, size)?;
    Ok(disk)
}

fn push<Implementation: Machine>(
    machine: &mut Implementation,
    piles: Handle,
    pile: i64,
    disk: Handle,
) -> Outcome<()> {
    machine.enter(&[pile], &[piles, disk])?;
    let top = machine.read_link(piles, pile)?;
    machine.set_link(disk, NEXT, top)?;
    machine.write_link(piles, pile, disk)?;
    machine.leave();
    Ok(())
}

fn pop<Implementation: Machine>(
    machine: &mut Implementation,
    piles: Handle,
    pile: i64,
) -> Outcome<Handle> {
    machine.enter(&[pile], &[piles])?;
    let top = machine.read_link(piles, pile)?;
    let next = machine.link(top, NEXT)?;
    machine.write_link(piles, pile, next)?;
    machine.leave();
    Ok(top)
}

fn shift<Implementation: Machine>(
    machine: &mut Implementation,
    towers: &mut Towers,
    from: i64,
    destination: i64,
) -> Outcome<()> {
    machine.enter(&[from, destination], &[towers.piles])?;
    let disk = pop(machine, towers.piles, from)?;
    push(machine, towers.piles, destination, disk)?;
    towers.moves = machine.add(towers.moves, 1)?;
    machine.leave();
    Ok(())
}

fn solve<Implementation: Machine>(
    machine: &mut Implementation,
    towers: &mut Towers,
    disks: i64,
    ends: (i64, i64),
) -> Outcome<()> {
    let (from, destination) = ends;
    machine.enter(&[disks, from, destination], &[towers.piles])?;
    if disks == 1 {
        shift(machine, towers, from, destination)?;
    } else {
        let partial = machine.subtract(3, from)?;
        let other = machine.subtract(partial, destination)?;
        let fewer = machine.subtract(disks, 1)?;
        solve(machine, towers, fewer, (from, other))?;
        shift(machine, towers, from, destination)?;
        solve(machine, towers, fewer, (other, destination))?;
    }
    machine.leave();
    Ok(())
}

pub fn run<Implementation: Machine>(machine: &mut Implementation, size: i64) -> Outcome<String> {
    let piles = machine.array(3)?;
    let mut pile = 0;
    while pile <= 2 {
        let base = machine.add(size, 1)?;
        let sentinel = disk(machine, base)?;
        machine.write_link(piles, pile, sentinel)?;
        pile = machine.add(pile, 1)?;
    }
    let mut size_left = size;
    while size_left >= 1 {
        let next = disk(machine, size_left)?;
        push(machine, piles, 0, next)?;
        size_left = machine.subtract(size_left, 1)?;
    }
    let mut towers = Towers { piles, moves: 0 };
    solve(machine, &mut towers, size, (0, 1))?;
    machine.settle()?;
    Ok(towers.moves.to_string())
}
