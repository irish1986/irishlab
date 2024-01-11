<img src="https://camo.githubusercontent.com/5b298bf6b0596795602bd771c5bddbb963e83e0f/68747470733a2f2f692e696d6775722e636f6d2f7031527a586a512e706e67" align="left" width="144px" height="144px"/>

# irishlab

... where I learn Architecture, Infrastructure, Networking, DevOps, and a few others things.

This is a mono repository for my homelab infrastructure and kubernetes cluster implementing Infrastructure as Code (IaC) and GitOps practices using tools like [Kubernetes](https://kubernetes.io/), [Flux](https://github.com/fluxcd/flux2), [Renovate](https://github.com/renovatebot/renovate) and [GitHub Actions](https://github.com/features/actions).

Feel free to open a [Github issue](https://github.com/irish1986/homelab/issues/new/choose) if you have any questions.

## Overview

---

## Architecture

### Rack

I currently lack the physical space to deploy a full size server rack but it is a project of mine.  At the moment, I am using two (2) wall mounted network rack which beside the obvious issue of not handling full size server are great.  I also host two (2) Tripp Lite UPS, one for each rack, for power protection.

I have purchase a [RPi4 UCTRONICS 1U Rack Mount](https://www.uctronics.com/amp/raspberry-pi/1u-rack-mount/uctronics-1u-rack-with-poe-functionality-for-raspberry-pi-4-19-1u-rackmount-supports-1-6-units.html) that can fit up to six (6) Raspberry Pi 4 with Power-Over-Ethernet.

### Hardware

I am mostly running consumer grade hardware and single board computers

| Device           | Count | OS Disk Size | Data Disk Size                       | Ram   | Purpose                             |
| ---------------- | ----- | ------------ | -------------------------------------| ----- | ----------------------------------- |
| 2U Server        | 1     | 120GB SSD    | 2x1TB NVME Cache<br/>4x1TB SSD ZFS   |  32GB | NAS Server<br/>Soon Commissioned    |
| 4U Server        | 1     | 2x120GB SSD  | 2x1TB NVME Cache<br/>12x10TB HDD ZFS | 128GB | NAS Server<br/>Soon Commissioned    |
| 4U Workstation   | 1     | 2x1TB NVME   | None                                 |  64GB | Daily Driver<br/>Gaming Workstation |
| Dell Micro 5060  | 7     | 120GB SSD    | 1x500GB NVME                         |  32GB | Proxmox and CEPH cluster            |
| Dell Wyze 5060   | 1     |  64GB SSD    | None                                 |  32GB | Proxmox test cluster                |
| Jetson Nano      | 1     |  32GB SD     | 128GB USB                            |   4GB | Edge Node and CUDA Workload         |
| Raspberry Pi4    | 1     |  32GB SD     | None                                 |   4GB | KVM Node                            |
| Raspberry Pi4    | 1     |  32GB USB    | 128GB USB                            |   4GB | Edge Node and DNS Server            |
| Raspberry Pi4    | 6     |  32GB USB    | 128GB USB                            |   8GB | Edge Node and K3S Server            |
| Synology DS1812+ | 1     | None         | 8x10TB SHR-2                         |   2GB | NAS Server<br/>Soon Decommissioned  |
| Synology DS218J  | 1     | None         | 2x4TB SHR-2                          |   2GB | NAS Server<br/>Off-site Backup      |

### Networking

I am running a TP-Link Omada medium stack.

### KVM

I bought a PiKVM V3 a while back and I planning on deploying a TESMart 16 HDMI KVM Switch in a near future for baremetal KVM interactivity.

### Fun Stuff

I do host a few other devices in my lab such Lutron hub, HD HomeRun TV, external Blu-Ray drive, etc...

## Operating System

### PiKVM

### Proxmox

This cluster is not hyper-converged as block storage is provided by the underlying PVE CEPH cluster using rook-ceph-external.

### Ubuntu OS

The cluster is running on a mixed of [Ubuntu Server](https://ubuntu.com/server) some deployed on bare-metal and other as virtual machine.  Ubuntu Server is great given it support of AMD64 and ARM64 architecture.  Finally, I am running various version of Ubuntu depending on the workload requirement (i.e.: newer kernel for specific hardware).

- [Ubuntu 20.04.6 LTS Focal Fossa](https://releases.ubuntu.com/focal/)
- [Ubuntu 22.04.3 LTS Jammy Jellyfish](https://releases.ubuntu.com/jammy/)
- [Ubuntu 23.04 Lunar Lobster](https://releases.ubuntu.com/lunar/)
- [Ubuntu 23.10.1 Mantic Minotaur](https://releases.ubuntu.com/mantic/)

Template are provisioned using Promox template using [Ubuntu Cloud Image](https://cloud-images.ubuntu.com/) which are slightly smaller that standard ISO image and more optimized for cloud native application.  There is [Ubuntu Minimal Cloud Images](https://cloud-images.ubuntu.com/minimal/releases/) which I would like to explore even more.

- [Ubuntu 20.04.6 LTS Focal Fossa](https://releases.ubuntu.com/focal/)
- [Ubuntu 22.04.3 LTS Jammy Jellyfish](https://releases.ubuntu.com/jammy/)
- [Ubuntu 23.04 Lunar Lobster](https://releases.ubuntu.com/lunar/)
- [Ubuntu 23.10.1 Mantic Minotaur](https://releases.ubuntu.com/mantic/)

### Synology

My DS1812+ was commissioned in March 2014 and has been my first dip in the world of homelabbing.  It has been my primary server for quite a while and my main network attach storage for almost a decade.  It been through many disks configuration, software upgrade as well couple of power supplies but in [early October 2023, Synology End-of-Life Announcement for DSM 6.2](https://www.synology.com/en-us/products/status/eol-dsm62) means this device sunset as come.  Given it been my workhorse for many years I have learn quite a lot from it and my greatest lesson is to **move away from proprietary ecosystem**.  Finally, I do have an extra DS218J located at my parents house as my primary offsite backup for invaluable data.

## Hypervisor

### PCI-E Passthrough

## Infrastructure as Code

### Cloud Init

### Terraform

This cluster consists of VMs provisioned on [PVE](https://www.proxmox.com/en/proxmox-ve) via the [Terraform Proxmox provider](https://github.com/Telmate/terraform-provider-proxmox).

### Ansible

These run [k3s](https://k3s.io/) using the [Ansible](https://www.ansible.com/) playbook of my own.

## Kubernetes

This repo generally attempts to follow the structure and practices of the excellent [k8s-at-home/template-cluster-k3](https://github.com/k8s-at-home/template-cluster-k3s), check it out if you're uncomfortable starting out with an immutable operating system.

### K3S

The cluster is running on a mixed of [Ubuntu AMD64 Cloud Image](https://cloud-images.ubuntu.com/) deployed via Terraform as virtual mac2hine on my Proxmox cluster.

- **Server nodes** (aka control node) are defined as a host running the `k3s server` command, with control-plane and datastore components managed by K3s.
  - One (1) node is  running [Focal Fossa](https://releases.ubuntu.com/focal/)
  - Two (2) nodes are running [Jammy Jellyfish](https://releases.ubuntu.com/jammy/).  Eventually I will upgrade one to [Noble Numbat](https://www.omgubuntu.co.uk/2023/10/ubuntu-24-04-release-date-set-for-april-25-2024).

- **Agent nodes** (aka worker node) are defined as a host running the `k3s agent` command, without any datastore or control-plane components.  These nodes are a mixed and match of version in order to test against a large set:
  - one (1) is running [Focal Fossa](https://releases.ubuntu.com/focal/)
  - one (1) is running [Jammy Jellyfish](https://releases.ubuntu.com/jammy/)
  - one (1) is running [Lunar Lobster](https://releases.ubuntu.com/lunar/)
  - one (1) is running [Mantic Minotaur](https://releases.ubuntu.com/mantic/)

On top of this cluster is extent onto six (6) [Raspberry Pi4 8GB](https://www.raspberrypi.com/products/raspberry-pi-4-model-b/) which are power via POE.  [Ubuntu Server ARM64 Jammy Jellyfish](https://releases.ubuntu.com/jammy/) is running on these which are even splitted between server and agent nodes.  

In the end, this K3S cluster is multi-architecture running a varieties of operating system, linux kernel and heterogeneous configuration.

### Core

- [kube-vip](https://kube-vip.io/) provides Kubernetes clusters with a virtual IP and load balancer for both the control plane (for building a highly-available cluster) and Kubernetes Services of type LoadBalancer without relying on any external hardware or software.
- [metal-lb](https://metallb.universe.tf/) is a load-balancer implementation for bare metal Kubernetes clusters, using standard routing protocols.
- [longhorn](https://longhorn.io/) is a distributed block storage system for Kubernetes.
- [rook-ceph](https://rook.io/): Provides persistent volumes, allowing any application to consume RBD block storage from the underlying PVE cluster.
- [traefik](https://traefik.io/): Provides ingress cluster services.
- [rancher](https://www.rancher.com/) is an open source container management platform built for organizations that deploy containers in production.
- [kured](https://github.com/kubereboot/kured) is a daemonset that performs safe automatic node reboots when the need to do so is indicated by the package management system of the underlying OS.
- [sops](https://toolkit.fluxcd.io/guides/mozilla-sops/): Encrypts secrets which is safe to store - even to a public repository.

### Repository structure

The Git repository contains the following directories under `cluster` and are ordered below by how Flux will apply them.

- **base** directory is the entrypoint to Flux
- **crds** directory contains custom resource definitions (CRDs) that need to exist globally in your cluster before anything else exists
- **core** directory (depends on **crds**) are important infrastructure applications (grouped by namespace) that should never be pruned by Flux
- **apps** directory (depends on **core**) is where your common applications (grouped by namespace) could be placed, Flux will prune resources here if they are not tracked by Git anymore

```
./cluster
├── ./apps
├── ./base
├── ./core
└── ./crds
```

## GitOps

[Flux](https://github.com/fluxcd/flux2) watches my [cluster](./cluster/) folder (see Directories below) and makes the changes to my cluster based on the YAML manifests.

[Dependabot](https://github.com/dependabot) watches my **github action directory** looking for dependency updates, when they are found a PR is automatically created. When PRs are merged, applies the changes to my repo.

[Renovate](https://github.com/renovatebot/renovate) watches my **entire** repository looking for dependency updates, when they are found a PR is automatically created. When PRs are merged, [Flux](https://github.com/fluxcd/flux2) applies the changes to my cluster.

## Reference, Resources & Links

A big thank you goes to these awesome people and their projects who inspired me to do this project.  In no specific order

- [billimek/k8s-gitops](https://github.com/billimek/k8s-gitops)
- [clayshek/homelab-monorepo](https://github.com/clayshek/homelab-monorepo)
- [diromns/home-cluster](https://github.com/Diromns/home-cluster)
- [geerlingguy](https://www.jeffgeerling.com/)
- [onedr0p/home-ops](https://github.com/onedr0p/home-ops)
- [pascaliske/infrastructure](https://github.com/pascaliske/infrastructure)
- [pikubernetescluster](https://picluster.ricsanfre.com/)
- [rpi4cluster](https://rpi4cluster.com/)
- [technotim](https://technotim.live/)

Also I want to thank you the awesome [`k8s-at-home` community](https://github.com/k8s-at-home/) for all their work on [their Helm Charts](https://github.com/k8s-at-home/charts) which helped me a lot.

## License

[MIT](LICENSE.md) – © 2023 [Simon HARVEY](https://irishlab.io)
