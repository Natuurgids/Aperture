# Managing Offline Maps

Aperture displays maps entirely from locally installed map packages. The Map workspace does not download tiles while it is being used.

## Prepare maps before field work

Use **Maintenance Center → Manage Offline Maps** before travelling. Load a configured Aperture map catalog, then browse its hierarchy from continent to country and onward to the provider-defined regional unit. The usual lowest downloadable unit is a province, state, department, county, or comparable region.

Download only the coverage needed for the next field period. Regional increments are easier to verify, continue after interruption, update, and remove. Very large selections consume both installation storage and temporary verification space.

Before a download starts, Aperture shows:

- download size;
- estimated installed size;
- temporary working space;
- free space on the map-package drive.

A large-package warning recommends using smaller regional increments. It is guidance, not a restriction.

## Import a complete map bundle

When a complete prebuilt collection is available, use **Import Map Bundle** instead of downloading its regions individually. Aperture accepts `.apkg` map bundles containing:

- `bundle.json`;
- one or more MBTiles files;
- a SHA-256 checksum and package metadata for every file.

Aperture verifies every package before registration. Invalid, incomplete, unsafe, or checksum-mismatched bundle contents are not activated.

A bundle can be copied by USB drive or other offline media. Importing a bundle never contacts a public map server.

## Updates, enablement, and removal

Installed packages can be enabled, disabled, replaced by a verified newer package, or removed to recover space. Removing a basemap package does not remove:

- photo GPS coordinates;
- observation locations;
- monitoring sites;
- saved scientific regions;
- movement history.

If no enabled package covers the current view, Aperture keeps the Map workspace available and reports that offline map coverage is unavailable.

## Map source policy

Aperture does not create offline archives by bulk-downloading from public OpenStreetMap tile servers. Catalogs and bundles must provide licensed, prebuilt Aperture-compatible MBTiles packages with checksums, attribution, and licence metadata.


## Geofabrik OpenStreetMap provider

Aperture uses the official Geofabrik region index as its default online map source. An internet connection is required to retrieve the catalog and selected regional extract. Only leaf regions offered by the provider are downloadable in the normal interface. NatureAI Next verifies the provider file when a checksum sidecar is available, converts the regional shapefile extract locally into raster MBTiles, and registers the finished package with Aperture. Installed maps then work without a network connection. Public OpenStreetMap tile servers are never bulk-downloaded.

## Background preparation and progress

Selected regions are queued as separate background activities. You can close the Offline Maps window and continue using Aperture. Open **Activity Center** to see the current phase, download speed, bytes transferred, rendered tile count, completion, cancellation, or retry. Progress is refreshed once per second to avoid slowing the transfer or map creation.


## Viewing installed areas

The Maps workspace lists enabled installed map packages in the **Area** selector. Choose an area and select **Zoom to Area** to center the viewer on its stored coverage. When the current view has no coverage, opening or explicitly refreshing Maps centers on the first enabled installed area. Pan and zoom remain available, and locations outside downloaded coverage show a clear offline-coverage message.
