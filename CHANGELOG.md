## [1.0.1] - 2025-10-31
### Fixed
- Sesiones NFC: cierre garantizado con `finish()` en `finally` para evitar PlatformException(503).
- Lectura/escritura con modelos de alto nivel (`ndef`) sin choques de tipos.

### Added
- Soporte Smart Poster y AAR (`AARRecord`).
- Servicios separados: lector y escritor, más mantenible.

### Changed
- Uso de `TextRecord`, `UriRecord`, `SmartPosterRecord` y `AARRecord`.
