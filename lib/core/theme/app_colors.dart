import 'package:flutter/material.dart';

/// Tokens de color exactos del sistema de diseño de la web (Tailwind),
/// trasladados literalmente para que el cliente Flutter sea fiel al look
/// original.
abstract final class AppColors {
  // Marca (naranja) — brand.500 es el acento principal.
  static const brand50 = Color(0xFFFFF4E5);
  static const brand100 = Color(0xFFFFE8CC);
  static const brand200 = Color(0xFFFFD199);
  static const brand300 = Color(0xFFFFB84D);
  static const brand400 = Color(0xFFFFA31A);
  static const brand500 = Color(0xFFFF9500);
  static const brand600 = Color(0xFFE6850A);
  static const brand700 = Color(0xFFCC7A00);
  static const brand800 = Color(0xFFA35F00);
  static const brand900 = Color(0xFF7A4700);

  // Fondo de ventana/pantalla.
  static const windowBackgroundLight = Color(0xFFF5F5F7);
  static const windowBackgroundDark = Color(0xFF1C1C1E);

  // Fondo de barra lateral/nav.
  static const navBackgroundLight = Color(0xFFF6F6F8);
  static const navBackgroundDark = Color(0xFF252527);

  // Fondo de superficie (tarjetas).
  static const surfaceLight = Color(0xFFFFFFFF);
  static const surfaceDark = Color(0xFF2C2C2E);

  // Línea divisoria (hairline).
  static const hairlineLight = Color.fromRGBO(0, 0, 0, 0.08);
  static const hairlineDark = Color.fromRGBO(255, 255, 255, 0.09);

  // Texto.
  static const textPrimaryLight = Color(0xFF1C1C1E);
  static const textPrimaryDark = Color(0xFFF5F5F7);
  static const textSecondaryLight = Color.fromRGBO(0, 0, 0, 0.55);
  static const textSecondaryDark = Color.fromRGBO(255, 255, 255, 0.6);
}
