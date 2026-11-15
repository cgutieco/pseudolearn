import { DEVICE_FRAMES, FOLD_AXES, type Device } from "./catalog_types.ts";
import type { JsonObject, JsonReader } from "./json_reader.ts";

const DEVICE_KEYS = ["id", "logicalWidth", "logicalHeight", "plateScale", "cornerRadius", "frame", "fold"];
const LOGICAL_RANGE = { min: 100, max: 4096 };

export function parseDevices(reader: JsonReader, document: JsonObject): ReadonlyMap<string, Device> {
  const devices = new Map<string, Device>();
  reader.array(document["devices"], "devices").forEach((value, index) => {
    const device = parseDevice(reader, reader.object(value, `devices[${index}]`), `devices[${index}]`);
    if (devices.has(device.id)) {
      reader.fail("devices", `duplicate device id ${device.id}`);
    }
    devices.set(device.id, device);
  });
  return devices;
}

function parseDevice(reader: JsonReader, entry: JsonObject, path: string): Device {
  reader.keys(entry, path, DEVICE_KEYS);
  const device: Device = {
    id: reader.text(entry["id"], `${path}.id`),
    logicalWidth: reader.number(entry["logicalWidth"], `${path}.logicalWidth`, LOGICAL_RANGE),
    logicalHeight: reader.number(entry["logicalHeight"], `${path}.logicalHeight`, LOGICAL_RANGE),
    plateScale: reader.number(entry["plateScale"], `${path}.plateScale`, { min: 1, max: 3 }),
    cornerRadius: reader.number(entry["cornerRadius"], `${path}.cornerRadius`, { min: 0, max: 120 }),
    frame: reader.member(entry["frame"], `${path}.frame`, DEVICE_FRAMES),
    fold: reader.member(entry["fold"], `${path}.fold`, FOLD_AXES),
  };
  if ((device.frame === "foldable") !== (device.fold !== "none")) {
    reader.fail(`${path}.fold`, "only a foldable frame has a fold axis, and it always has one");
  }
  return device;
}
