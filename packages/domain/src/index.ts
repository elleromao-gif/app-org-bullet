export function normalizeTagName(value: string): string {
  return value.trim().replace(/\\s+/g, ' ').toLocaleLowerCase();
}

export function isValidISODate(value: string): boolean {
  return !Number.isNaN(Date.parse(value));
}
