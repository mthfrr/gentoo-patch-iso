#!/bin/sh

set -e

log() {
	scope=$1
	shift
	printf "[+] %s: %s\n" "$scope" "$@"
}

[ $# -ne 2 ] && echo "Usage: $0 iso_file output_iso" && exit 1

log summary "patching $1 -> $2"
github_user=mthfrr
log summary "user $github_user"

log env "creating folders"
root=$(mktemp -d /tmp/iso-patch.XXXXXX)

lower="$root/lower"
upper="$root/upper"
work="$root/work"
merged="$root/merged"
iso="$root/iso"
new="$root/new.squashfs"

sqfs="$iso/image.squashfs"

for d in "$lower" "$upper" "$work" "$merged" "$iso"; do
	mkdir -p "$d"
done

log env "folder root=$root"

log iso "unpacking $1"
7z x "$1" -o"$iso" -y

log grub "patching cmdline"
sed -i -e 's/timeout=.*/timeout=1/' -e 's/dokeymap/nokeymap dosshd/' "$iso"/boot/grub/grub.cfg

log squashfs "injecting ssh pubkey in overlay"
curl -q "https://github.com/$github_user.keys" | sudo install -D -o 0 -g 0 -m 0400 /dev/stdin "$upper"/root/.ssh/authorized_keys

log squashfs "mounting as overlay"
unmount_all() {
	sudo umount -fq "$merged" "$lower"
}
trap clean_up EXIT
sudo mount "$sqfs" "$lower"
sudo mount -t overlay overlay -olowerdir="$lower",upperdir="$upper",workdir="$work" "$merged"
log squashfs "rebuilding squashfs"
sudo mksquashfs "$merged" "$new" -comp xz -b 1M -noappend
sudo chown "$USER:$USER" "$new"
log squashfs "unmount"
sudo umount -fq "$merged" "$lower"
trap '-' EXIT

log squashfs "swaping to new"
mv "$new" "$sqfs"

log iso "repacking to $2"
mkisofs -o "$2" -b boot/gentoo -c boot.catalog -no-emul-boot -boot-load-size 4 -boot-info-table -J -R -V "Gentoo Patched" "$iso"

log env "clean up"
sudo rm -rf "$root"
