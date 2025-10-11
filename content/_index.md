---
title: knot
layout: index
description: Self hosted solution for managing cloud development environments.
---

{{< big-title
  title="Cloud Development Environment Orchestrator"
>}}

{{< hero
  title="Local Speed. Global Consistency"
  subtitle="Spin up secure and governed environments in seconds. Knot brings together cloud and local runtimes including Nomad, Docker, Podman and Apple Containers. Roles, groups and templates scale across regions so developers work close to home for low latency while teams everywhere share the same consistent workflows."
  btn1="Get Started"
  btn1Link="docs/quick-start/"
  btn2="Learn More"
  btn2Link="docs"
  img="/images/hero.webp"
  alt="Managing Spaces"
>}}

{{< feature-grid >}}

  {{< feature-row
    reverse=true
    img="/images/setup.webp"
    alt="Scale With Remote Clusters"
    is4=true
  >}}
  ## Effortless Setup & Scalability
  Set up your developer environment once and reuse it anytime. Seamlessly scale with remote clusters for optimal performance near your team.
  {{< /feature-row >}}

  {{< feature-row
    reverse=true
    img="/images/anywhere.webp"
    alt="Self Hosted"
    is4=true
  >}}
  ## Complete Control, Anywhere
  Self-hosted on your infrastructure with fine-grained access control. Manage containers, users, and environments from anywhere.
  {{< /feature-row >}}
{{< /feature-grid >}}

{{< feature-grid >}}
  {{< feature-row
    reverse=false
    img="/images/cloud.webp"
    alt="Cloud Development"
    is4=true
  >}}
  ## Cloud-Ready Development
  Code directly in your browser with tools like Code Server or Visual Studio Code Tunnels, supported by built-in dev utilities.
  {{< /feature-row >}}

  {{< feature-row
    reverse=false
    img="/images/team.webp"
    alt="Roles and Groups"
    is4=true
  >}}
  ## Smart Team Collaboration
  Organize users and templates into groups for tailored access, ensuring efficient and secure teamwork.
  {{< /feature-row >}}
{{< /feature-grid >}}

{{< feature-row
  reverse=true
  img="/images/cluster.webp"
  alt="Leaderless Cluster"
>}}
## Decentralized Management
Leaderless cluster management eliminates single point of failure, ensuring greater reliability and resilience. By supporting remote clusters or servers located near your team, this approach minimizes latency, delivering faster and more responsive performance for users.
{{< /feature-row >}}

---

## Why Choose knot?

knot is an open-source tool (Apache 2.0 License) for managing environments within a Nomad cluster or standalone using Local Containers (Docker, Podman, or Apple Container). With its leaderless architecture, you can manage your development environments from anywhere, ensuring flexibility and reliability. Whether you're working locally or scaling across remote servers, knot simplifies the process, so you can focus on development.
