# NixOS

My NixOS configuration: flake, Home Manager, Sway, ephemeral btrfs root,
Limine with Secure Boot.

## Layout

```
hosts/<name>/        hostname, stateVersion and facter.json of each machine
modules/nixos/       system modules, shared by all hosts
modules/home/        Home Manager modules
install.sh           installer for the NixOS live ISO
```

Every directory in `hosts/` becomes `nixosConfigurations.<name>`. All files in
`modules/` are imported automatically with
[import-tree](https://github.com/denful/import-tree); new files must be added
to git to be seen by the flake.

## Usage

```sh
nh os switch              # rebuild and switch
nh os boot                # rebuild, switch on next boot
nix flake update          # update inputs
nix fmt                   # format
nix flake check           # evaluate all hosts
```

Older generations can be picked from the Limine menu, or with
`sudo nixos-rebuild switch --rollback`.

## Install on a new machine

The example below installs a machine called `my-laptop`. Use any short name
with letters, digits and dashes.

### 1. Create the USB stick

Download the NixOS minimal ISO from https://nixos.org/download and write it to
a USB stick, which erases the stick:

- Linux: `sudo dd if=nixos-minimal.iso of=/dev/sdX bs=4M status=progress conv=fsync`
  (find `sdX` with `lsblk`)
- Windows: [Rufus](https://rufus.ie), in DD mode

### 2. Boot the installer

1. Disable Secure Boot in the firmware settings (usually F2, F10 or Del at
   power-on).
2. Boot from the USB stick (boot menu, usually F12, F9 or Esc).
3. Connect to the network with `nmtui`.
4. Become root with `sudo -i`.

### 3. Get this configuration

```sh
nix-shell -p git
git clone https://github.com/ErasedMemoir/NixOs
cd NixOs
```

### 4. Add the machine

```sh
mkdir hosts/my-laptop
cat > hosts/my-laptop/default.nix <<'EOF'
{
  networking.hostName = "my-laptop";
  hardware.facter.reportPath = ./facter.json;
  system.stateVersion = "26.05";
}
EOF
git add hosts/my-laptop
./install.sh facter my-laptop
```

Set `system.stateVersion` to the NixOS version of the ISO and never change it
afterwards. `hosts/hp15` also holds fixes for that laptop model only; do not
copy them.

The last command detects the hardware and writes
`hosts/my-laptop/facter.json`.

### 5. Partition the disk

```sh
lsblk
./install.sh format my-laptop /dev/nvme0n1
```

Replace `/dev/nvme0n1` with the disk shown by `lsblk`. Everything on that
disk is erased.

### 6. Install

```sh
./install.sh install my-laptop
```

It asks for the user password, then installs the system. Reboot and remove
the USB stick.

### 7. After the first boot

Enable Secure Boot as described below, then save the new machine:

```sh
cd /etc/nixos
git add hosts/my-laptop
git commit -m "Add my-laptop"
gh auth login
git push
```

If the installation stopped after step 5, mount the disk again with
`./install.sh mount my-laptop /dev/nvme0n1` and repeat step 6.

## Secure Boot

The keys are created during the installation and stored in
`/var/lib/sbctl`. To enroll them:

1. In the firmware settings, reset Secure Boot to Setup Mode (often called
   "Clear keys" or "Delete all keys").
2. Boot NixOS and run
   `sudo sbctl enroll-keys --microsoft --firmware-builtin`.
3. Reboot into the firmware settings and enable Secure Boot.
4. Check with `sbctl status`.

If `/var/lib/sbctl` is empty, create the keys first with
`sudo sbctl create-keys && nh os boot`.

If the machine does not boot, disable Secure Boot in the firmware and run
`sudo sbctl verify`.

## Persistence

`/` is recreated on every boot. Only `/nix`, `/home`, `/data` and `/boot`
survive. State that must be kept is declared with
`preservation.preserveAt."/data"` in the module that uses it.

## Password

The user password hash is read from `/data/secrets/erased.hash`. If the file
is missing the account is locked, so create it before switching:

```sh
sudo install -d -m 700 /data/secrets
nix run nixpkgs#mkpasswd -- -m yescrypt | sudo tee /data/secrets/erased.hash > /dev/null
sudo chmod 600 /data/secrets/erased.hash
```

## Notes

- Intel, AMD and NVIDIA hardware is configured from `facter.json`. NVIDIA
  GPUs (GTX 16xx or newer) use the open driver and the LTS kernel, because the
  driver does not always build against the latest one.
- Power profile: performance on AC or above 60 % battery, balanced from 21 to
  60 %, power-saver below. It can be fixed until reboot from the `set` panel
  of the bar. See `modules/nixos/hardware/power-policy.nix`.
- The bar, panels and volume indicator are in `modules/home/eww`.
- Cloudflare WARP is toggled from the `net` panel; the first use registers
  the device.
- Bluetooth is disabled in `modules/nixos/hardware/bluetooth.nix`.
