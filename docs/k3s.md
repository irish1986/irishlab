# k3s

This is my k3s cluster with kube-vip.

## How to run

```shell
pipx install --include-deps netaddr
sudo apt install --no-install-recommends python3-netaddr
```

## Ceph consideration

Tripe node PVE Cluster
Use physical separate disks used for the PVE install, k8s VMs and Longhorn
Don't put k8s VMs or Longhorn on HDDs, only use SSDs or NVMe
Evenly spread out your k8s masters and workers across each PVE node
In a 3 master/3 worker setup put one master on each PVE node and one worker on each PVE node.
Instead of Longhorn, consider setting up a Ceph cluster on your PVE nodes and use Rook to consume it for stateful applications. Due to the way Ceph works in this scenerio, it is fine to use HDDs over SSDs or NVMe here.
