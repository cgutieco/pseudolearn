import type { Catalog } from "../catalog/catalog_types.ts";
import { buildAppIcon } from "../compose/app_icon.ts";
import type { Manifest } from "./manifest.ts";
import type { Outcome, Toolbox } from "./ports.ts";
import { produceStill } from "./produce_still.ts";
import type { Job } from "./render_plan.ts";

export type AppIconJob = {
  readonly toolbox: Toolbox;
  readonly catalog: Catalog;
  readonly job: Job;
  readonly outputRoot: string;
};

export function produceAppIcon(request: AppIconJob): Promise<Outcome<Manifest>> {
  const { job } = request;
  if (job.slot.kind !== "app-icon") {
    return Promise.resolve({ ok: false, error: `${job.slot.id} is not an app icon` });
  }
  const composition = buildAppIcon(`app-icon-${job.slot.width}`, job.slot);
  return produceStill({ ...request, composition, assets: [], findings: [] });
}
