import mermaid from "mermaid";

const theme = () =>
  document.documentElement.classList.contains("dark") ? "dark" : "default";

function snapshot() {
  document.querySelectorAll("pre.mermaid").forEach((el) => {
    if (!el.dataset.source) el.dataset.source = el.textContent;
  });
}

function render() {
  snapshot();
  mermaid.initialize({
    startOnLoad: false,
    theme: theme(),
    securityLevel: "loose",
    flowchart: { useMaxWidth: true, htmlLabels: true },
  });
  mermaid.run({ nodes: [...document.querySelectorAll("pre.mermaid")] });
}

function rerender() {
  document.querySelectorAll("pre.mermaid").forEach((el) => {
    el.removeAttribute("data-processed");
    el.innerHTML = el.dataset.source || "";
  });
  render();
}

if (document.readyState === "loading") {
  document.addEventListener("DOMContentLoaded", render);
} else {
  render();
}

// Re-render diagrams when the light/dark theme is toggled.
new MutationObserver((mutations) => {
  for (const m of mutations) {
    if (m.attributeName === "class") {
      rerender();
      break;
    }
  }
}).observe(document.documentElement, { attributes: true, attributeFilter: ["class"] });
