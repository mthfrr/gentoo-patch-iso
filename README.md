<!-- vim: spelllang=en
<!-- LTeX: language=en -->

# Gentoo ISO patching tool

## About

This script modifies a bootable Gentoo ISO to facilitate unattended installation.

This script:

- reduces `grub`'s timeout to 1 sec
- enables `sshd` at boot
- adds the `ssh` public keys from a GitHub account to `authorized_keys`

## Dependencies

- cdrtools (mkisofs)
- curl
- mksquashfs (mksquashfs)
- p7zip
- sed
- sudo

## Usage

Running this script requires `sudo` to be available.

```sh
# ⚠  edit the script to change your GitHub username
./patch.sh source.iso patched.iso
```
