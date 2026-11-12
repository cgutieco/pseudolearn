import { describe, expect, it } from "vitest";
import { contains } from "../../src/layout/pixel_rect.ts";
import { REVIEW_CELL_WIDTH, REVIEW_GUTTER, reviewBoardLayout } from "../../src/layout/review_board_layout.ts";
import { slot } from "../support/catalog.ts";

const header = slot("apple.header.video");

describe("reviewBoardLayout", () => {
  it("lays out one row per sample and one column for the canvas plus each device crop", () => {
    const board = reviewBoardLayout(header, [0, 2.5, 5, 7.5]);
    expect(board.rows).toHaveLength(4);
    expect(board.rows[0]?.cells.map((cell) => cell.label)).toEqual(["canvas", ...header.viewportProfiles.map((profile) => profile.name)]);
    expect(board.size.width).toBe(REVIEW_GUTTER + 7 * (REVIEW_CELL_WIDTH + REVIEW_GUTTER));
  });

  it("shows the whole canvas in the first column and the official zone inside it", () => {
    const canvasCell = reviewBoardLayout(header, [0]).rows[0]?.cells[0];
    expect(canvasCell?.image).toEqual(canvasCell?.clip);
    expect(contains(canvasCell!.clip, canvasCell!.safe)).toBe(true);
  });

  it("crops the sides of the 21:9 canvas on an iPhone and keeps the zone visible", () => {
    const phone = reviewBoardLayout(header, [0]).rows[0]?.cells[1];
    expect(phone!.image.width).toBeGreaterThan(phone!.clip.width);
    expect(phone!.image.height).toBeCloseTo(phone!.clip.height, 6);
    expect(contains(phone!.clip, phone!.safe)).toBe(true);
  });

  it("draws only the canvas column for a slot without device crops", () => {
    expect(reviewBoardLayout(slot("apple.search.video"), [0]).rows[0]?.cells).toHaveLength(1);
  });

  it("returns a title-only board when there are no samples", () => {
    expect(reviewBoardLayout(header, []).rows).toEqual([]);
  });
});
