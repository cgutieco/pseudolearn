export function long(first: number, second: number, third: number): number {
  let total = first;
  if (second > 0) {
    if (third > 0) {
      total += second + third;
    }
  }
  return total;
}

export class Wide {
  one(): number {
    return 1;
  }

  two(): number {
    return 2;
  }
}
