/* Mapa Leaflet — paridad mod_mapa.R (polígonos reales + clustering) */
const AcrMap = (() => {
  let map = null;
  let clusterGroup = null;
  const layerRefs = { acr: null, zi: null, limites: null };

  function init() {
    if (map) return map;
    map = L.map("map", { scrollWheelZoom: true, preferCanvas: true }).setView([-7.5, -74.5], 6);

    const osm = L.tileLayer("https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", {
      attribution: "© OpenStreetMap",
      maxZoom: 18,
    });
    const sat = L.tileLayer(
      "https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}",
      { attribution: "© Esri", maxZoom: 18 }
    );
    const topo = L.tileLayer(
      "https://server.arcgisonline.com/ArcGIS/rest/services/World_Topo_Map/MapServer/tile/{z}/{y}/{x}",
      { attribution: "© Esri", maxZoom: 18 }
    );
    osm.addTo(map);

    clusterGroup = L.markerClusterGroup({
      maxClusterRadius: 80,
      disableClusteringAtZoom: 15,
      spiderfyOnMaxZoom: true,
    });

    L.control.scale({ imperial: false, position: "bottomleft" }).addTo(map);

    map._baseLayers = {
      "🗺️ Calles (OSM)": osm,
      "🛰️ Satelital (Esri)": sat,
      "⛰️ Topográfico": topo,
    };
    map._overlayReady = false;
    return map;
  }

  function geoLayer(geo, style, groupName) {
    if (!geo || !geo.features || !geo.features.length) return null;
    return L.geoJSON(geo, {
      style: () => style,
      onEachFeature: (feature, layer) => {
        const p = feature.properties || {};
        if (p.popup_html) layer.bindPopup(p.popup_html, { maxWidth: 320 });
        if (p.Nombre) layer.bindTooltip(p.Nombre, { sticky: true });
        layer.options.groupName = groupName;
      },
    });
  }

  function clearLayers() {
    if (!map) return;
    Object.values(layerRefs).forEach((l) => {
      if (l) map.removeLayer(l);
    });
    layerRefs.acr = layerRefs.zi = layerRefs.limites = null;
    if (clusterGroup) {
      clusterGroup.clearLayers();
      map.removeLayer(clusterGroup);
    }
  }

  function addLegend() {
    if (map._legend) map.removeControl(map._legend);
    map._legend = L.control({ position: "bottomright" });
    map._legend.onAdd = () => {
      const div = L.DomUtil.create("div", "map-legend");
      div.innerHTML = `<div style="background:#fff;padding:10px;border-radius:6px;font-size:12px;line-height:1.6">
        <b>🔍 Leyenda del Mapa</b><br>
        <span style="color:#4CAF50">■</span> ACR<br>
        <span style="color:#9E9E9E">■</span> Zona de Influencia<br>
        <span style="color:#d32f2f">●</span> Deforestación (cluster)
      </div>`;
      return div;
    };
    map._legend.addTo(map);
  }

  function setupLayerControl() {
    if (map._layerControl) map.removeControl(map._layerControl);
    const overlays = {};
    if (layerRefs.acr) overlays["ACRs"] = layerRefs.acr;
    if (layerRefs.zi) overlays["Zonas de Influencia"] = layerRefs.zi;
    if (layerRefs.limites) overlays["Límites Departamentales"] = layerRefs.limites;
    overlays["🔴 Deforestación"] = clusterGroup;

    map._layerControl = L.control.layers(map._baseLayers, overlays, { collapsed: false }).addTo(map);
  }

  const DEPTO_CODES = {
    loreto: ["ACR_AA", "ACR_ANPCH", "ACR_MK", "ACR_CTT", "ZI_AA", "ZI_ANPCH", "ZI_MK", "ZI_CTT"],
    san_martin: ["ACR_BSM", "ACR_CE", "ZI_BSM", "ZI_CE"],
    cusco: ["ACR_CHQ", "ACR_CHU", "ACR_QK", "ZI_CHQ", "ZI_CHU", "ZI_QK"],
  };

  function filterPoints(points, state) {
    let pts = points;
    if (state.ambito === "acr") pts = pts.filter((p) => p.tipo === "acr");
    else if (state.ambito === "zi") pts = pts.filter((p) => p.tipo === "zi");
    if (state.departamento !== "todos") {
      const allowed = new Set(DEPTO_CODES[state.departamento] || []);
      pts = pts.filter((p) => allowed.has(p.codigo));
    }
    if (state.acrs.length) {
      const allowed = new Set([...state.acrs, ...state.acrs.map((c) => c.replace("ACR_", "ZI_"))]);
      pts = pts.filter((p) => allowed.has(p.codigo));
    }
    if (state.annoDesde != null && state.annoHasta != null) {
      const lo = Math.min(state.annoDesde, state.annoHasta);
      const hi = Math.max(state.annoDesde, state.annoHasta);
      pts = pts.filter((p) => {
        const y = parseInt(p.anno, 10);
        return !Number.isNaN(y) && y >= lo && y <= hi;
      });
    }
    return pts;
  }

  async function loadDeforestation(state) {
    const params = {
      departamento: state.departamento,
      ambito: state.ambito || "acr",
      acr: state.acrs.length ? state.acrs : undefined,
      anno_desde: state.annoDesde,
      anno_hasta: state.annoHasta,
      limit: 0,
    };
    const data = await apiGet("/api/deforestacion/centroides", params);
    const points = filterPoints(data.data || [], state);
    if (!points.length) {
      console.info("Sin puntos de deforestación para los filtros activos (incl. año).");
    }
    points.forEach((p) => {
      if (!p.lon || !p.lat) return;
      const m = L.circleMarker([p.lat, p.lon], {
        radius: 5,
        color: "#c0392b",
        fillColor: "#e74c3c",
        fillOpacity: 0.75,
        weight: 1,
      });
      m.bindPopup(
        `<div style="font-family:Arial;min-width:200px">
          <h4 style="color:#d32f2f;margin:0 0 8px">🔴 Deforestación</h4>
          <b>Zona:</b> ${String(p.codigo).replace(/^(ACR_|ZI_)/, "")}<br>
          <b>Tipo:</b> ${p.tipo === "acr" ? "ACR" : "ZI"}<br>
          <b>Año:</b> ${p.anno || "N/A"}<br>
          <b>Área:</b> <span style="color:#d32f2f">${Number(p.area).toFixed(4)} ha</span>
        </div>`
      );
      clusterGroup.addLayer(m);
    });
    map.addLayer(clusterGroup);
  }

  async function refresh(state) {
    init();
    clearLayers();

    const params = {
      departamento: state.departamento,
      ambito: state.ambito || "acr",
      acr: state.acrs.length ? state.acrs : undefined,
    };

    const layers = await apiGet("/api/map/layers", params);

    if (!layers.geojson_ready) {
      console.warn("Ejecute exportar_datos.bat para polígonos ACR/ZI");
    }

    const limColors = { LORETO: "#006D5B", SAN_MARTIN: "#D32F2F", CUSCO: "#FF6F00" };
    if (layers.limites) {
      layerRefs.limites = geoLayer(
        layers.limites,
        (f) => ({
          color: limColors[f.properties.codigo] || "#333",
          weight: 2,
          fillOpacity: 0,
          dashArray: "5,5",
        }),
        "limites"
      );
      if (layerRefs.limites) layerRefs.limites.addTo(map);
    }

    if (layers.zi) {
      layerRefs.zi = geoLayer(
        layers.zi,
        { fillColor: "#9E9E9E", fillOpacity: 0.25, color: "#616161", weight: 2 },
        "zi"
      );
      if (layerRefs.zi) layerRefs.zi.addTo(map);
    }

    if (layers.acr) {
      layerRefs.acr = geoLayer(
        layers.acr,
        { fillColor: "#4CAF50", fillOpacity: 0.4, color: "#2E7D32", weight: 2.5 },
        "acr"
      );
      if (layerRefs.acr) {
        layerRefs.acr.addTo(map);
        try {
          map.fitBounds(layerRefs.acr.getBounds(), { padding: [30, 30], maxZoom: 9 });
        } catch (_) {}
      }
    }

    await loadDeforestation(state);
    setupLayerControl();
    addLegend();
    setTimeout(() => map.invalidateSize(), 300);
  }

  return { init, refresh };
})();
