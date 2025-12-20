// Formats scaled ingredient quantities in the browser. Mirrors Quantity.format
// in app/models/quantity.rb so a rescaled amount reads exactly like one the
// server rendered.

const FRACTIONS = [
  [0, 1], [1, 8], [1, 4], [1, 3], [3, 8], [1, 2], [5, 8], [2, 3], [3, 4], [7, 8], [1, 1],
]
const TOLERANCE = 0.03

// Two decimals under 10, one under 100, whole numbers above that.
export function formatDecimal(value) {
  const abs = Math.abs(value)
  const digits = abs < 10 ? 2 : abs < 100 ? 1 : 0
  const factor = 10 ** digits
  const rounded = Math.round(value * factor) / factor
  return String(rounded)
}

// 1.5 => "1 1/2", 0.333 => "1/3", 2 => "2"
export function formatFraction(value) {
  let whole = Math.floor(value)
  const rest = value - whole
  let best = FRACTIONS[0]
  for (const fraction of FRACTIONS) {
    if (Math.abs(rest - fraction[0] / fraction[1]) < Math.abs(rest - best[0] / best[1])) best = fraction
  }
  if (Math.abs(rest - best[0] / best[1]) > TOLERANCE) return formatDecimal(value)

  let [numerator, denominator] = best
  if (numerator === denominator) {
    whole += 1
    numerator = 0
  }
  if (numerator === 0) return String(whole)

  const part = `${numerator}/${denominator}`
  return whole === 0 ? part : `${whole} ${part}`
}

export function formatQuantity(value, style) {
  if (value === null || value === undefined || Number.isNaN(value)) return ""
  return style === "decimal" ? formatDecimal(value) : formatFraction(value)
}

// "1 1/2 cups", "250 g", "2" - singular unit names for one or less.
export function formatAmount(value, { style, unit, unitPlural } = {}) {
  const quantity = formatQuantity(value, style)
  if (!unit) return quantity

  const label = value <= 1 ? unit : unitPlural || unit
  return `${quantity} ${label}`
}

export function scaleFactor(servings, baseServings) {
  const target = Number(servings)
  const base = Number(baseServings)
  if (!Number.isFinite(target) || !Number.isFinite(base) || target <= 0 || base <= 0) return 1
  return target / base
}
