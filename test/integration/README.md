# OpenBSD integration tests

This adds **real QEMU + Beaker testing** to PR #509 for OpenBSD 7.9 and 8.0.
It does not claim that a guessed Vagrant box, Docker image, or private pool exists.

## Every pull request

`.github/workflows/openbsd-qemu.yml` runs a matrix with 7.9 and 8.0:

1. Check the `vmpooler`, `abs`, `vagrant`, `vagrant_libvirt`, `docker`,
   and `none` generated configurations for OS-info versions 0 and 1.
2. Verify template, box, and image overrides are preserved.
3. Boot a real OpenBSD image under QEMU (`vmactions/openbsd-vm`).
4. Test OpenBSD identity, architecture, SSH forwarding, and root login.
5. Run Beaker against the live guest using `hypervisor: none`, including
   basic OS commands, package-tool availability, and SCP file transfer.

**Scope:** This is a real OpenBSD compatibility test. It does **not** mean
that Beaker's provisioners can create OpenBSD VMs, because `none` uses a
QEMU guest provisioned independently by the VM action.

## Optional real provisioning

Use the **OpenBSD QEMU integration** workflow's **Run workflow** button
and choose `provision_backend` other than `none`.

The additional `provision` matrix uses a **self-hosted Linux x86-64 runner**
with label `beaker-provisioning`. The runner must be trusted and configured
with Ruby/Bundler, Beaker, the chosen Beaker provider plugin, SSH access to
its VMs, and necessary provider credentials. Do **not** give self-hosted
provisioning access to untrusted pull-request code; the provisioning job is
only manually runnable from a workflow_dispatch event.

| `provision_backend` | Required inputs | Runner prerequisites |
|---|---|---|
| `vagrant_libvirt` | `vagrant_box_79` and `vagrant_box_80` | `vagrant`, libvirt/QEMU, `vagrant-libvirt` Vagrant plugin, `beaker-vagrant` Ruby gem; working libvirt connection; verified libvirt boxes that boot OpenBSD |
| `vmpooler` | `template_79` and `template_80` | `beaker-vmpooler` gem, reachable VMPooler API, credentials, actual OpenBSD pools |
| `abs` | `template_79` and `template_80` | `beaker-abs` gem, ABS_RESOURCE_HOSTS or vmfloaty configuration, SSH credentials, actual OpenBSD pools |

If a required image, pool, or plugin is absent, the provisioning job **fails**,
instead of reporting a misleading pass. Neither VMPooler nor ABS can be tested
on generic public GitHub runners without access to those private services.
The configured provider plugin must return reachable SSH hosts.

## Docker is not a native OpenBSD test on Linux

The `docker` generator's guessed `amd64/openbsd:XX` image names are checked
as generated metadata, but launching an ordinary Docker container on a
Linux host does not provide an OpenBSD kernel. Do not treat a Docker image
pull attempt as verification of an OpenBSD machine.

## Security and cleanup

The QEMU matrix uses a temporary per-job SSH key. The private provisioning
job uses operator-supplied machines and access. Keep provider credentials in
the runner's protected configuration rather than commit them. Beaker is
invoked with `--preserve-hosts never` in the optional job; verify provider
cleanup rules before enabling it against shared infrastructure.

## Public image inventory (non-gating)

The regular CI also makes best-effort queries for `generic/openbsd79` and
`generic/openbsd80` Vagrant boxes and the generated Docker image names.
Those results are displayed in the job summary and **never** imply successful
provisioning. Network or registry outages are not counted as a passed VM test.

The Beaker integration test runs in separate workflow steps for OS/SSH,
SCP upload/download, and read-only native package/database operations.
There are no package-installation side effects on OpenBSD hosts.
