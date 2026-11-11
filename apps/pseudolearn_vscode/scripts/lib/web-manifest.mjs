export const desktopOnlyCommands = Object.freeze([
  "pseudolearn.debugFile",
  "pseudolearn.debugProject",
  "pseudolearn.createAgentInstructions",
]);

export function browserCommandContributions(commands) {
  return commands.filter((entry) => !desktopOnlyCommands.includes(entry.command));
}

export function menusForCommands(menus, commands) {
  const available = new Set(commands.map((entry) => entry.command));
  return Object.fromEntries(Object.entries(menus ?? {}).map(([location, items]) =>
    [location, items.filter((item) => available.has(item.command))]));
}
