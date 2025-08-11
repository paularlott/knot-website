---
title: "Changelog"
description: "Keep track of all changes, updates, and improvements to knot."
layout: "changelog"
draft: false
weight: 100
---

## August 2025

{{< version "v0.19.0" >}}

{{< changelog-item "added" >}}
- **Run In Space**:
  Run commands within a space via the command line client.
{{< /changelog-item >}}

## July 2025

{{< version "v0.18.2" >}}

This release introduces significant updates, with the most notable being a complete rewrite of the cluster mode. The new leaderless architecture ensures that all servers in the cluster are equal, eliminating the need for a designated leader. This change improves both availability and performance, allowing the system to continue functioning seamlessly even if connections between nodes are interrupted.

{{< changelog-item "added" >}}
- **Enhanced Tunneling**:
  Tunnel functionality has been improved, enabling the creation of tunnels from a port within a space to a port on the local machine.
- **Leaf Node Support**:
  Restructured leaf nodes to work seamlessly with the new cluster mode.
- **Cluster Management**:
  - Added support for multiple servers within a location/zone.
  - Enhanced cluster startup code and introduced a cluster info API endpoint.
- **DNS Server**:
  Implemented a basic DNS server with forwarding support.
- **Backup and Restore**:
  - Added encryption to backup/restore functionality.
  - Enabled support for audit logs and configuration values in backup/restore.
- **Template Enhancements**:
  - Templates can now define variables, which are made available when creating a space.
  - Added the ability to mark templates as inactive.
  - Introduced a duplicate template function for easier template management.
- **Space Management**:
  - Added a "space note" feature for descriptions and notes.
  - Introduced a restart command for spaces in both the UI and CLI.
  - Enabled forwarding into spaces without requiring port specifications.
- **UI/UX Enhancements**:
  - Added usage graphs for better resource monitoring.
  - Improved login screen, added white-label support, and refined the user list UI.
  - Added icons to spaces and templates, including Gravatar support in share dialogs.
- **Miscellaneous**:
  - Added IP rate limiting for authentication to enhance security.
{{< /changelog-item >}}

{{< changelog-item "changed" >}}
- **UI/UX Enhancements**:
  - Enhanced feedback for over-quota errors and improved messaging across the UI.
- **Performance and Reliability**:
  - Refined tunnel handling and connection management with improved logging and synchronization.
  - Improved data flow between servers in the same zone.
  - Extended token life to two weeks for better user experience.
- **CLI Updates**:
  - Refactored CLI commands for better organization and usability.
  - Added support for managing multiple servers from the CLI.
  - Improved error handling and feedback in the CLI.
- **Code Refactoring**:
  - Removed deprecated commands and unused code for a cleaner codebase.
  - Replaced the `viper` dependency with an internal CLI package for improved performance.
- **Audit Log**:
  - Enhanced audit log handling and forwarding to clusters for better traceability.
- **Templates**:
  - Added platform change warning modals to template and volume forms for better user guidance.
{{< /changelog-item >}}

{{< changelog-item "fixed" >}}
- Fixed issues with standalone spaces and manual space deletion.
- Resolved incorrect termination of the main server loop.
- Addressed storage quota bugs.
- Corrected permission checks for space transfers and admin roles.
- Fixed the SSH info window not closing properly.
{{< /changelog-item >}}

---
