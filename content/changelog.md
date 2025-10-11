---
title: "Changelog"
description: "Keep track of all changes, updates, and improvements to knot."
layout: "changelog"
draft: false
weight: 100
---

## October 2025

{{< version "v0.20.x" >}}

{{< changelog-item "added" >}}
- **Apple Container Support**:
  Added support for Apple Container templates using the macOS container CLI.
{{< /changelog-item >}}

{{< changelog-item "changed" >}}
- **Safari**:
  Improved the web interface compatibility with Safari.
- **HTTP/2 Errors**:
  HTTP/2 errors and no longer fatal, they are logged and knot continues operation.
- **UI**:
  Minor UI improvements.
- **Cluster**:
  Improvements to data synchronization.
{{< /changelog-item >}}

## September 2025

{{< version "v0.19.1" >}}

{{< changelog-item "changed" >}}
- **Message History UX**:
  Improvements to the usability of the message history.
{{< /changelog-item >}}

{{< version "v0.19.0" >}}

This release brings Artificial Intelligence to **knot**, with both a built in assistant and connectivity to use with editors and applications that support MCP.

{{< changelog-item "added" >}}
- **Model Content Protocol (MCP)**:
  Added ability to use knot servers as MCP servers exporting tools for creating and managing spaces and templates.
- **AI Assistant**:
  Added web based AI assistant allowing control of spaces and templates including assistance in writing new templates (requires OpenAI compatible LLM).
- **Run In Space**:
  Run commands within a space via the command line client.
- **Copy Files**:
  Copy files between the local machine and the space.
- **Soft Keyboard**:
  When accessing **knot** from a tablet the terminal window now has a soft keyboard which provides cursor keys, control key and other keys that are not generally available on the keyboard.
{{< /changelog-item >}}

{{< changelog-item "changed" >}}
- **Tunnel Server**:
  Allow running the tunnel server on the same port as the main web interface.
- **Nomad Volumes**:
  Added support for Nomads builtin `mkdir` storage plugin.
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
