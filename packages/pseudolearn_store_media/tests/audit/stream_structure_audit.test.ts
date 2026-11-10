import { describe, expect, it } from "vitest";
import { auditStreamStructure } from "../../src/audit/stream_structure_audit.ts";
import type { StreamStructure } from "../../src/audit/video_audit.ts";
import { slot } from "../support/catalog.ts";
import { closedGopStructure } from "../support/probe.ts";

const trailer = slot("microsoft.trailer").video!.codecProfile;
const preview = slot("apple.iphone.app-preview").video!.codecProfile;
const good = closedGopStructure(2);

function messages(structure: Partial<StreamStructure>, profile = trailer): readonly string[] {
  return auditStreamStructure({ profile, target: "t.mp4", framesPerSecond: 30, structure: { ...good, ...structure } })
    .map((entry) => `${entry.rule}: ${entry.message}`);
}

describe("auditStreamStructure", () => {
  it("accepts a fast-start file with a closed 15-frame GOP and runs of two B frames", () => {
    expect(messages({})).toEqual([]);
  });

  it("rejects a file whose moov follows the media data or was not read", () => {
    expect(messages({ boxOrder: ["ftyp", "free", "mdat", "moov"] })).toEqual(["MEDIA-CONTAINER: boxes ftyp free mdat moov do not put moov before mdat (fast start)"]);
    expect(messages({ boxOrder: [] })).toEqual(["MEDIA-CONTAINER: boxes unread do not put moov before mdat (fast start)"]);
  });

  it("rejects edit lists only where the profile forbids them", () => {
    expect(messages({ editLists: 2 })).toEqual(["MEDIA-CONTAINER: 2 edit lists where the store forbids them"]);
    expect(messages({ editLists: 2, pictureTypes: "IBBP", keyFrames: [0] }, preview)).toEqual([]);
  });

  it("rejects key frames that do not fall every half second", () => {
    expect(messages({ keyFrames: [0] })).toEqual(["MEDIA-CODEC: key frames at 0 instead of every 15 frames"]);
    expect(messages({ keyFrames: [0, 15, 30, 44] })).toEqual(["MEDIA-CODEC: key frames at 0, 15, 30, 44 instead of every 15 frames"]);
    expect(messages({ pictureTypes: "", keyFrames: [] })[0]).toBe("MEDIA-CODEC: key frames at none instead of every 15 frames");
  });

  it("rejects an open GOP whose B frames lean on the next key frame", () => {
    const open = `${"IBBPBBPBBPBBPBB".repeat(3)}I`;
    expect(messages({ pictureTypes: open, keyFrames: [0, 15, 30, 45] })).toEqual(["MEDIA-CODEC: B frames before key frames 15, 30, 45 reach across the GOP"]);
  });

  it("rejects three B frames in a row and a stream with none", () => {
    expect(messages({ pictureTypes: good.pictureTypes.replace("IBBPBBP", "IBBBPBP") })).toEqual(["MEDIA-CODEC: 3 consecutive B frames instead of up to 2"]);
    expect(messages({ pictureTypes: good.pictureTypes.replace(/B/gu, "P") })).toEqual(["MEDIA-CODEC: 0 consecutive B frames instead of up to 2"]);
  });

  it("skips GOP and B-frame checks for profiles that do not set them", () => {
    expect(messages({ pictureTypes: "IBBBBP", keyFrames: [0] }, preview)).toEqual([]);
  });
});
