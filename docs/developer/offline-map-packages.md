# Offline Map Catalogs and Bundles

## Catalogs

An Aperture map catalog is a JSON hierarchy. Navigational entries may represent continents, countries, states, regions, or provinces. Downloadable entries must provide:

- a stable `entry_id`;
- `downloadable: true`;
- `format: mbtiles`;
- an HTTPS `download_url`;
- a 64-character SHA-256 value;
- package version, bounds, zoom range, licence, and attribution where available.

The provider defines the administrative hierarchy. Aperture does not assume that every country has the same levels.

## Aperture map bundles

A map bundle uses the `.apkg` extension and is a ZIP archive with this structure:

```text
bundle.json
packages/<package>.mbtiles
```

`bundle.json` must declare:

```json
{
  "bundle_format": "aperture-map-bundle",
  "schema_version": 1,
  "name": "Prepared field maps",
  "packages": [
    {
      "entry_id": "stable-package-id",
      "name": "Region name",
      "region_type": "province",
      "package_version": "2026.07",
      "package_path": "packages/region.mbtiles",
      "sha256": "...",
      "bounds": [4.0, 50.0, 6.0, 52.0]
    }
  ]
}
```

Bundle paths must be relative and must not contain parent traversal. Every embedded file is extracted to a private temporary directory, hashed, structurally validated as MBTiles, and atomically moved into Aperture-managed storage before activation.

## Operational rules

- Never point catalogs at public OpenStreetMap tile endpoints for bulk acquisition.
- Regenerate checksums after producing final MBTiles files.
- Package replacement is atomic: the existing package remains usable until the replacement verifies.
- Catalog or bundle failure must not affect the core Aperture Library.


## Geofabrik OpenStreetMap provider

Aperture uses the official Geofabrik region index as its default online map source. An internet connection is required to retrieve the catalog and selected regional extract. Only leaf regions offered by the provider are downloadable in the normal interface. NatureAI Next verifies the provider file when a checksum sidecar is available, converts the regional shapefile extract locally into raster MBTiles, and registers the finished package with Aperture. Installed maps then work without a network connection. Public OpenStreetMap tile servers are never bulk-downloaded.
