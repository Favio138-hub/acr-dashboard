/* Tarjetas «Datos Relevantes por Región» — datos reales desde API */
const RegionInsights = (() => {
  const TITLE_STYLES = {
    loreto: "background:linear-gradient(135deg,#f1c40f,#f39c12);color:#fff;padding:12px;border-radius:6px;margin:-8px -8px 16px",
    sanmartin: "background:linear-gradient(135deg,#f8c471,#f39c12);color:#fff;padding:12px;border-radius:6px;margin:-8px -8px 16px",
    cusco: "background:linear-gradient(135deg,#5cb85c,#4cae4c);color:#fff;padding:12px;border-radius:6px;margin:-8px -8px 16px",
  };

  let modalData = {};

  function cardClass(id) {
    if (id === "loreto") return "region-card-loreto";
    if (id === "sanmartin") return "region-card-sanmartin";
    return "region-card-cusco";
  }

  function renderMetric(m) {
    return `<li><i class="fas ${m.icon}" style="color:${m.color}"></i> ${m.text}</li>`;
  }

  function renderCard(r) {
    const metrics = (r.metrics || []).slice(0, 3);
    return `
      <article class="region-card ${cardClass(r.id)}" style="--region-accent:${r.accent}">
        <span class="region-badge">${r.label}</span>
        <div class="region-card-head">
          <div class="region-icon-wrap" style="background:${r.accent}22;color:${r.icon_color}">
            <i class="fas ${r.icon}"></i>
          </div>
          <h4 class="region-card-title">${r.title}</h4>
        </div>
        <p class="region-desc">${r.summary}</p>
        <ul class="region-facts">${metrics.map(renderMetric).join("")}</ul>
        <div class="region-link-wrap">
          <button type="button" class="region-link" data-region="${r.id}">
            Ver análisis completo <i class="fas fa-arrow-right"></i>
          </button>
        </div>
      </article>`;
  }

  function buildModalPayload(r) {
    const modal = r.modal || {};
    const sections = (modal.sections || [])
      .map(
        (s) => `
        <div class="modal-region-block" style="border-color:${r.accent}">
          <h5><i class="fas fa-chart-bar" style="color:${r.accent}"></i> ${s.title}</h5>
          ${s.html}
        </div>`
      )
      .join("");

    return {
      title: modal.title || r.label,
      titleStyle: TITLE_STYLES[r.id] || TITLE_STYLES.loreto,
      stats: modal.stats || [],
      body: `<h4 style="color:#1a4d2e"><i class="fas fa-database"></i> Basado en monitoreo acumulado</h4>${sections}`,
    };
  }

  function render(root, payload) {
    const regions = payload?.regions || [];
    modalData = {};
    regions.forEach((r) => {
      modalData[r.id] = buildModalPayload(r);
    });

    root.innerHTML = `
      <div class="region-insights-header">
        <p class="region-insights-meta">
          <i class="fas fa-sync-alt"></i> Actualizado desde datos de deforestación (${payload?.periodo || "2001–2025"})
        </p>
      </div>
      <div class="region-cards">${regions.map(renderCard).join("")}</div>`;
  }

  function renderSkeleton(root) {
    root.innerHTML = `<div class="region-cards region-cards-loading">
      ${[1, 2, 3].map(() => `<div class="region-card region-card-skeleton"></div>`).join("")}
    </div>`;
  }

  async function load() {
    const root = document.getElementById("region-insights-root");
    if (!root) return;
    renderSkeleton(root);
    try {
      const res = await fetch("/api/region-insights");
      if (!res.ok) throw new Error("API error");
      const data = await res.json();
      render(root, data);
      Modals.bindRegionCards();
    } catch (err) {
      console.error("RegionInsights:", err);
      root.innerHTML = `<p class="region-insights-error">No se pudieron cargar los datos regionales.</p>`;
    }
  }

  function getModal(region) {
    return modalData[region] || null;
  }

  return { load, getModal };
})();
