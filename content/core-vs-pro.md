---
title: Knot Core vs Knot Pro
description: Compare the open-source Knot Core release with Knot Pro and see which features are available in each.
hideSidebar: true
---

## Choose the Edition That Fits Your Team

**Knot Core** is the open-source Apache 2.0 edition for teams that want a self-hosted platform for managed development environments with full control over infrastructure and deployment.

**Knot Pro** builds on Core with commercial features for authentication, security, observability, and operator workflows.

<div class="compare-intro-grid">
  <section class="compare-intro-card compare-intro-card-core">
    <p class="compare-kicker">Knot Core</p>
    <h3>Open source and production ready</h3>
    <p>Run Knot as a single server or across multiple servers using Docker, Podman, or Apple Containers with no extra control plane.</p>
    <ul>
      <li>Apache 2.0 licensed</li>
      <li>Self-hosted web UI and CLI</li>
      <li>Templates, spaces, roles, groups, volumes, AI, and clustering</li>
    </ul>
  </section>
  <section class="compare-intro-card compare-intro-card-pro">
    <p class="compare-kicker">Knot Pro</p>
    <h3>Advanced controls for growing teams</h3>
    <p>Add commercial features that help larger teams standardize login, access, activity visibility, and secret handling.</p>
    <ul>
      <li>Includes everything in Core</li>
      <li>License-gated server features</li>
      <li>Commercial binaries and container images</li>
    </ul>
  </section>
</div>

---

## Feature Comparison

<div class="compare-table-wrap">
  <table class="compare-table">
    <thead>
      <tr>
        <th>Area</th>
        <th>Knot Core</th>
        <th>Knot Pro</th>
      </tr>
    </thead>
    <tbody>
      <tr>
        <td><strong>License</strong></td>
        <td>Apache 2.0 open source</td>
        <td>Commercial licensed edition</td>
      </tr>
      <tr>
        <td><strong>Deployment models</strong></td>
        <td>Single server, multi-server, leaf nodes, Nomad support</td>
        <td>Everything in Core</td>
      </tr>
      <tr>
        <td><strong>Runtime support</strong></td>
        <td>Docker, Podman, Apple Containers</td>
        <td>Everything in Core</td>
      </tr>
      <tr>
        <td><strong>Spaces and templates</strong></td>
        <td>Managed spaces, templates, volumes, startup scripts, terminal, SSH, Code Server, VS Code Tunnels</td>
        <td>Everything in Core</td>
      </tr>
      <tr>
        <td><strong>Access control</strong></td>
        <td>Users, groups, roles, permissions, quotas</td>
        <td>Everything in Core</td>
      </tr>
      <tr>
        <td><strong>AI and MCP</strong></td>
        <td>AI assistant, skills, MCP server, MCP tools, Scriptling</td>
        <td>Everything in Core</td>
      </tr>
      <tr>
        <td><strong>OAuth / OIDC sign-in</strong></td>
        <td><span class="compare-no">Not included</span></td>
        <td><span class="compare-yes">Included</span> GitHub, GitLab, Google, Auth0, and compatible OIDC providers</td>
      </tr>
      <tr>
        <td><strong>Disable password auth</strong></td>
        <td><span class="compare-no">Not included</span></td>
        <td><span class="compare-yes">Included</span> when OAuth providers are configured</td>
      </tr>
      <tr>
        <td><strong>Secret providers</strong></td>
        <td><span class="compare-no">Not included</span></td>
        <td><span class="compare-yes">Included</span> external secret resolution for Vault and 1Password Connect</td>
      </tr>
      <tr>
        <td><strong>Visual port forwarding</strong></td>
        <td><span class="compare-no">Not included</span></td>
        <td><span class="compare-yes">Included</span> UI-driven forwarded port management</td>
      </tr>
      <tr>
        <td><strong>Audit log filtering</strong></td>
        <td><span class="compare-no">Not included</span></td>
        <td><span class="compare-yes">Included</span> richer audit log search and filtering workflows</td>
      </tr>
      <tr>
        <td><strong>User and space activity views</strong></td>
        <td><span class="compare-no">Not included</span></td>
        <td><span class="compare-yes">Included</span> activity tracking with per-template disable controls</td>
      </tr>
      <tr>
        <td><strong>Commercial binaries</strong></td>
        <td><a href="https://github.com/paularlott/knot/releases">Open-source releases</a></td>
        <td><a href="https://github.com/paularlott/knot-pro/releases">Knot Pro releases</a></td>
      </tr>
      <tr>
        <td><strong>Container image</strong></td>
        <td><code>paularlott/knot</code></td>
        <td><code>paularlott/knot-pro</code></td>
      </tr>
    </tbody>
  </table>
</div>

---

## What Most Teams Choose

<div class="compare-path-grid">
  <section class="compare-path-card">
    <h3>Choose Core if you want</h3>
    <ul>
      <li>An open-source self-hosted platform</li>
      <li>CLI and web-based space management</li>
      <li>Templates, access control, clustering, and AI features without a commercial license</li>
      <li>To integrate your own authentication and secret workflows outside Knot</li>
    </ul>
  </section>
  <section class="compare-path-card">
    <h3>Choose Pro if you want</h3>
    <ul>
      <li>Everything included in Knot Core, plus commercial features for authentication, secrets, and observability</li>
      <li>OAuth or OIDC login for users</li>
      <li>External secret manager integration at render time</li>
      <li>Activity and audit workflows in the UI</li>
      <li>Additional operator convenience features for larger teams</li>
    </ul>
  </section>
</div>

---

## Get Started

<div class="compare-cta-band">
  <div>
    <p class="compare-kicker">Start with Core</p>
    <h3>Deploy the open-source edition</h3>
    <p>Use Knot Core if you want the Apache 2.0 release with self-hosted control over your infrastructure.</p>
    <p><a href="/docs/quick-start/">Read the quick start</a></p>
  </div>
  <div>
    <p class="compare-kicker">Upgrade to Pro</p>
    <h3>Unlock commercial features</h3>
    <p>Use Knot Pro if you need OAuth, secret providers, activity views, and other advanced operational features.</p>
    <p><a href="/docs/quick-start/pro-installation/">See Knot Pro installation</a></p>
  </div>
</div>
