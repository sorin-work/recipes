// Sends a request the way a Turbo form would and applies the turbo stream
// that comes back.
export async function turboStreamRequest(url, { method = "POST", body = {} } = {}) {
  const token = document.querySelector('meta[name="csrf-token"]')?.content
  const response = await fetch(url, {
    method,
    headers: {
      Accept: "text/vnd.turbo-stream.html",
      "Content-Type": "application/json",
      "X-CSRF-Token": token || "",
    },
    credentials: "same-origin",
    body: JSON.stringify(body),
  })

  const contentType = response.headers.get("Content-Type") || ""
  if (response.ok && contentType.includes("turbo-stream")) {
    window.Turbo.renderStreamMessage(await response.text())
    return true
  }
  return false
}
