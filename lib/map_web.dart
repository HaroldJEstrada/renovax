import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

import 'config.dart';

Widget buildEmbeddedMap() {
  final details = Uri.base.replace(fragment: '/acopio').toString();
  final center = jsonEncode({
    'name': Acopio.name,
    'lat': Acopio.latitude,
    'lng': Acopio.longitude,
    'details': details,
    'note': Acopio.locationNote,
  }).replaceAll('<', r'\u003c');
  return SizedBox(
    height: 340,
    child: HtmlElementView.fromTagName(
      tagName: 'iframe',
      onElementCreated: (element) {
        final frame = element as web.HTMLIFrameElement;
        frame.title = 'Mapa Leaflet del acopio ${Acopio.name}';
        frame.style.border = '0';
        frame.style.width = '100%';
        frame.style.height = '100%';
        // El documento hereda el origen para que las teselas reciban Referer.
        frame.setAttribute('referrerpolicy', 'strict-origin-when-cross-origin');
        frame.srcdoc =
            '''<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<meta name="referrer" content="strict-origin-when-cross-origin">
<link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css"
 integrity="sha256-p4NxAoJBhIIN+hmNHrzRCf9tD/miZyoHS5obTRR9BMY=" crossorigin="">
<style>
html,body,#map{height:100%;width:100%;margin:0}body{font:14px Arial,sans-serif;background:#e1edff;color:#1d385c}
#status{position:absolute;top:10px;left:52px;right:10px;z-index:1000;background:white;padding:10px;border-radius:8px;box-shadow:0 2px 8px #0002}
#status[hidden]{display:none}a{color:#294f90}.leaflet-control-attribution{font-size:11px}
</style>
</head>
<body>
<div id="map" role="region" aria-label="Mapa del centro de acopio"></div>
<div id="status" role="status">Cargando mapa…</div>
<script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"
 integrity="sha256-20nQCchB9co0qIjJZRGuk2/Z9VM+kNiyxNV1lvTlZBo=" crossorigin=""></script>
<script>
(function () {
  'use strict';
  const center = $center;
  const status = document.getElementById('status');
  function fallback(message) {
    status.replaceChildren(document.createTextNode(message + ' '));
    const link = document.createElement('a');
    link.href = 'https://www.openstreetmap.org/?mlat=' + center.lat + '&mlon=' + center.lng + '#map=17/' + center.lat + '/' + center.lng;
    link.target = '_blank'; link.rel = 'noopener noreferrer';
    link.textContent = 'Ver en OpenStreetMap'; status.appendChild(link); status.hidden = false;
  }
  if (typeof L === 'undefined') {
    fallback('No se pudo cargar Leaflet. Revisá tu conexión.'); return;
  }
  try {
    const map = L.map('map', {scrollWheelZoom: false}).setView([center.lat, center.lng], 16);
    map.attributionControl.setPrefix('<a href="https://leafletjs.com/" target="_blank" rel="noopener noreferrer">Leaflet</a>');
    const tiles = L.tileLayer('https://tile.openstreetmap.org/{z}/{x}/{y}.png', {
      maxZoom: 19,
      attribution: '&copy; <a href="https://www.openstreetmap.org/copyright" target="_blank" rel="noopener noreferrer">OpenStreetMap contributors</a>'
    });
    let failed = false;
    tiles.on('tileerror', function () { failed = true; fallback('No se pudieron cargar algunas partes del mapa.'); });
    tiles.on('load', function () { if (!failed) status.hidden = true; });
    tiles.addTo(map);
    const label = document.createElement('span'); label.textContent = center.name + ' · Ver información del acopio';
    const marker = L.marker([center.lat, center.lng], {title: center.name + ': abrir información del acopio', alt: center.name, keyboard: true}).addTo(map);
    marker.bindTooltip(label, {direction: 'top'});
    marker.on('click', function () { window.open(center.details, '_blank', 'noopener,noreferrer'); });
    window.addEventListener('resize', function () { map.invalidateSize(); });
    setTimeout(function () { map.invalidateSize(); }, 100);
  } catch (_) { fallback('No se pudo mostrar el mapa.'); }
}());
</script>
</body>
</html>''';
      },
    ),
  );
}
