/* Reportes y Descargas — ui.R tab 3 + server.R modales/descargas */
const Reportes = (() => {
  const MAPAS = {
    loreto: [
      {
        id: "aa",
        titulo: "ACR Ampiyacu Apayacu",
        img: "/mapas/MAPA_ACR_AA_page-0001.jpg",
        pdf: "/api/descargas/mapa/aa",
        fecha: "Noviembre 2025",
      },
      {
        id: "anpch",
        titulo: "ACR Alto Nanay",
        img: "/mapas/MAPA_ACR_ANPCH_page-0001.jpg",
        pdf: "/api/descargas/mapa/anpch",
        fecha: "Noviembre 2025",
      },
      {
        id: "ctt",
        titulo: "ACR Tamshiyacu Tahuayo",
        img: "/mapas/MAPA_ACR_CTT_page-0001.jpg",
        pdf: "/api/descargas/mapa/ctt",
        fecha: "Noviembre 2025",
      },
      {
        id: "mk",
        titulo: "ACR Maijuna Kichwa",
        img: "/mapas/MAPA_ACR_MK_page-0001.jpg",
        pdf: "/api/descargas/mapa/mk",
        fecha: "Noviembre 2025",
      },
    ],
    sanmartin: [
      {
        id: "boshumi",
        titulo: "ACR Bosques de Shunté y Mishollo",
        img: `/mapas/${encodeURIComponent("25NOV17_Mapa_de_deforestación_en_ACR_BOSHUMI_y_su_ZI_A2.jpg")}`,
        pdf: "/api/descargas/mapa/boshumi",
        fecha: "Enero 2026",
      },
      {
        id: "ce",
        titulo: "ACR Cordillera Escalera",
        img: `/mapas/${encodeURIComponent("25NOV17_Mapa_de_deforestación_en_ACR_CE_y_su_ZI_A2.jpg")}`,
        pdf: "/api/descargas/mapa/ce",
        fecha: "Enero 2026",
      },
    ],
    cusco: [
      {
        id: "chq",
        titulo: "ACR Choquequirao",
        img: "/mapas/MAPA_CHOQUE_DEF_page-0001.jpg",
        pdf: "/api/descargas/mapa/chq",
        fecha: "Noviembre 2025",
      },
      {
        id: "chu",
        titulo: "ACR Chuyapi Urusayhua",
        img: "/mapas/MAPA_CHUYAPI_ANEXO2_page-0001.jpg",
        pdf: "/api/descargas/mapa/chu",
        fecha: "Noviembre 2025",
      },
      {
        id: "qk",
        titulo: "ACR Q'eros Kosñipata",
        img: "/mapas/MAPA_QEROS_ANEXO3_page-0001.jpg",
        pdf: "/api/descargas/mapa/qk",
        fecha: "Noviembre 2025",
      },
    ],
  };

  function cardHtml(m) {
    return `<div class="card-mapa-nueva">
      <div class="card-mapa-thumb"><img src="${m.img}" alt="${m.titulo}" loading="lazy"/></div>
      <div class="card-mapa-body">
        <h5><i class="fas fa-leaf"></i> ${m.titulo}</h5>
        <p class="card-mapa-fecha"><i class="fas fa-calendar"></i> Actualizado: ${m.fecha}</p>
        <div class="card-mapa-actions">
          <button type="button" class="btn-mapa-ver" data-img="${m.img}" data-titulo="${m.titulo}">
            <i class="fas fa-search-plus"></i> Ver
          </button>
          <a class="btn-mapa-pdf" href="${m.pdf}" download>
            <i class="fas fa-download"></i> PDF
          </a>
        </div>
      </div>
    </div>`;
  }

  function renderGalleries() {
    Object.entries(MAPAS).forEach(([depto, items]) => {
      const el = document.getElementById(`mapas-${depto}`);
      if (!el) return;
      el.innerHTML = items.map(cardHtml).join("");
      el.classList.toggle("hidden", depto !== "loreto");
    });
  }

  function bindEvents() {
    document.getElementById("filtro_depto_mapas")?.addEventListener("change", (e) => {
      document.querySelectorAll(".map-gallery-section").forEach((s) => s.classList.add("hidden"));
      const el = document.getElementById(`mapas-${e.target.value}`);
      if (el) el.classList.remove("hidden");
    });

    document.getElementById("mapas-galleries")?.addEventListener("click", (e) => {
      const btn = e.target.closest(".btn-mapa-ver");
      if (!btn) return;
      Modals.showMap(btn.dataset.titulo, btn.dataset.img);
    });

    document.getElementById("btn-descargar-datos")?.addEventListener("click", () => {
      window.location.href = "/api/descargas/datos";
    });

    document.getElementById("btn-ver-informe")?.addEventListener("click", () => {
      Modals.showInformeCatalogo();
    });

    document.getElementById("mapas-galleries")?.addEventListener("click", async (e) => {
      const link = e.target.closest(".btn-mapa-pdf");
      if (!link) return;
      const href = link.getAttribute("href");
      if (!href?.startsWith("/api/")) return;
      e.preventDefault();
      const ok = await fetch(href, { method: "HEAD" }).then((r) => r.ok).catch(() => false);
      if (ok) window.location.href = href;
      else alert("Mapa PDF no disponible en este momento.");
    });
  }

  function init() {
    renderGalleries();
    bindEvents();
  }

  return { init };
})();
