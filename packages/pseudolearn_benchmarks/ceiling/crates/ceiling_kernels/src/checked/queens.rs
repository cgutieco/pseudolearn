use crate::machine::{Handle, Machine, Outcome};

struct Board {
    rows: Handle,
    rising: Handle,
    falling: Handle,
}

fn diagonals<Implementation: Machine>(
    machine: &mut Implementation,
    row: i64,
    column: i64,
    size: i64,
) -> Outcome<(i64, i64)> {
    let rising = machine.add(row, column)?;
    let shifted = machine.subtract(row, column)?;
    let widened = machine.add(shifted, size)?;
    Ok((rising, machine.subtract(widened, 1)?))
}

fn mark<Implementation: Machine>(
    machine: &mut Implementation,
    board: &Board,
    cells: (i64, i64, i64),
    value: i64,
) -> Outcome<()> {
    let (row, rising, falling) = cells;
    machine.write(board.rows, row, value)?;
    machine.write(board.rising, rising, value)?;
    machine.write(board.falling, falling, value)
}

fn free<Implementation: Machine>(
    machine: &mut Implementation,
    board: &Board,
    cells: (i64, i64, i64),
) -> Outcome<bool> {
    let (row, rising, falling) = cells;
    Ok(machine.read(board.rows, row)? != 0
        && machine.read(board.rising, rising)? != 0
        && machine.read(board.falling, falling)? != 0)
}

fn place<Implementation: Machine>(
    machine: &mut Implementation,
    board: &Board,
    column: i64,
    size: i64,
) -> Outcome<i64> {
    machine.enter(&[column, size], &[board.rows, board.rising, board.falling])?;
    let (column, size) = (machine.word(0), machine.word(1));
    if column == size {
        machine.leave();
        return Ok(1);
    }
    let mut total = 0;
    let mut row = 0;
    while row < size {
        let (rising, falling) = diagonals(machine, row, column, size)?;
        if free(machine, board, (row, rising, falling))? {
            mark(machine, board, (row, rising, falling), 0)?;
            let next = machine.add(column, 1)?;
            let nested = place(machine, board, next, size)?;
            total = machine.add(total, nested)?;
            mark(machine, board, (row, rising, falling), 1)?;
        }
        row = machine.add(row, 1)?;
        machine.tick();
    }
    machine.leave();
    Ok(total)
}

pub fn run<Implementation: Machine>(machine: &mut Implementation, size: i64) -> Outcome<String> {
    let board = Board {
        rows: machine.array(16)?,
        rising: machine.array(16)?,
        falling: machine.array(16)?,
    };
    let mut index = 0;
    while index <= 15 {
        mark(machine, &board, (index, index, index), 1)?;
        index = machine.add(index, 1)?;
    }
    let total = place(machine, &board, 0, size)?;
    machine.settle()?;
    Ok(total.to_string())
}
