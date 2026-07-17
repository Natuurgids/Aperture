# Aperture Backup & Recovery

Aperture includes a separate **Aperture Backup & Recovery** program, available from the desktop and the Aperture Start-menu folder. The Restore command in Aperture opens this companion application.

## Back up a library

1. Open **Aperture Backup & Recovery**.
2. Select **Back Up Library…**.
3. Choose a destination.
4. Aperture creates a transaction-consistent SQLite backup and checksum manifest.

## Restore a library

1. Open **Aperture Backup & Recovery**.
2. Select **Restore Library…** and choose a verified backup.
3. Read the warning: Aperture will close, the database will be restored, and Aperture will restart.
4. Approve the restore.

The companion asks a running Aperture window to close cleanly, creates an emergency pre-restore backup, validates the selected backup and restored SQLite database, performs the replacement, and restarts Aperture. Users do not run PowerShell.

If validation or replacement fails, the previous database is restored from the rollback copy and Aperture reports the failure.

Original photographs are not modified by database backup or restore.

## Backup history management

The standalone **Aperture Backup & Recovery** application lists verified backups for the selected library. Select an entry to verify it again, restore it, or delete the database backup together with its checksum manifest. Restoration still creates an emergency backup, closes Aperture cleanly, validates the selected database, and restarts Aperture after success.

## Visible restore progress

During restore, Aperture Maintenance Center remains open and reports each stage. When **Back Up and Restore** is selected, the emergency backup is created and verified before Aperture closes. Restore results are written to the Aperture log folder as `restore-history.jsonl`.
