import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

import 'config.dart';

Widget buildEmbeddedMap() {
  return SizedBox(
    height: 300,
    child: HtmlElementView.fromTagName(
      tagName: 'iframe',
      onElementCreated: (element) {
        final frame = element as web.HTMLIFrameElement;
        frame.src = Uri.https('www.google.com', '/maps/embed/v1/place', {
          'key': Acopio.mapsKey,
          'q': 'place_id:${Acopio.placeId}',
        }).toString();
        frame.title = 'Centro de acopio Escuela El Progreso';
        frame.style.border = '0';
        frame.style.width = '100%';
        frame.style.height = '100%';
        frame.setAttribute('referrerpolicy', 'no-referrer-when-downgrade');
        frame.setAttribute('allowfullscreen', '');
      },
    ),
  );
}
