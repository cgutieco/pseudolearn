export function escapeHtml(text: string): string {
  return text.replaceAll("&", "&amp;").replaceAll("<", "&lt;").replaceAll(">", "&gt;").replaceAll("\"", "&quot;");
}

export function rectStyle(rect: { x: number; y: number; width: number; height: number }): string {
  return `position:absolute;left:${rect.x}px;top:${rect.y}px;width:${rect.width}px;height:${rect.height}px;`;
}
