/* Reportes y Descargas — galería con miniaturas ligeras + carga diferida */
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

  const rendered = new Set();
  let activeDepto = "loreto";

  function thumbSrc(img) {
    const name = decodeURIComponent(img.split("/").pop() || "");
    return `/mapas/thumbs/${encodeURIComponent(name)}`;
  }

  function cardHtml(m) {
    const thumb = thumbSrc(m.img);
    return `<div class="card-mapa-nueva">
      <div class="card-mapa-thumb">
        <div class="card-mapa-skeleton" aria-hidden="true"></div>
        <img src="${thumb}" alt="${m.titulo}" loading="lazy" decoding="async"
             data-full="${m.img}" class="card-mapa-img"/>
      </div>
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

  function bindThumbLoad(img) {
    const hideSkeleton = () => {
      img.classList.add("loaded");
      img.parentElement?.querySelector(".card-mapa-skeleton")?.classList.add("hidden");
    };
    if (img.complete) hideSkeleton();
    else {
      img.addEventListener("load", hideSkeleton, { once: true });
      img.addEventListener("error", () => {
        img.src = img.dataset.full || img.src;
        hideSkeleton();
      }, { once: true });
    }
  }

  function renderDepartment(depto) {
    if (rendered.has(depto)) return;
    const el = document.getElementById(`mapas-${depto}`);
    const items = MAPAS[depto];
    if (!el || !items) return;
    el.innerHTML = items.map(cardHtml).join("");
    el.querySelectorAll(".card-mapa-img").forEach(bindThumbLoad);
    rendered.add(depto);
  }

  function showDepartment(depto) {
    activeDepto = depto;
    document.querySelectorAll(".map-gallery-section").forEach((s) => s.classList.add("hidden"));
    renderDepartment(depto);
    document.getElementById(`mapas-${depto}`)?.classList.remove("hidden");
  }

  function bindEvents() {
    document.getElementById("filtro_depto_mapas")?.addEventListener("change", (e) => {
      showDepartment(e.target.value);
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
    bindEvents();
    const sel = document.getElementById("filtro_depto_mapas");
    showDepartment(sel?.value || "loreto");
  }

  return { init };
})();
