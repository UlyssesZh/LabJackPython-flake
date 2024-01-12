# LabJackPython-flake

Porting [LabJackPython](https://labjack.com/pages/support/?doc=%2Fsoftware-driver%2Fexample-codewrappers%2Flabjackpython-for-ud-exodriver-u12-windows-mac-linux%2F)
to nixpkg on linux-x86_64
(for using on NixOS or installed by nix or Nix flakes).

I only ported to linux-x86_64 because I cannot test other platforms.
Pull requests are welcome.

## Usage

To use without installing, you can use [`nix develop`](https://nixos.org/manual/nix/stable/command-ref/new-cli/nix3-develop.html):

```shell
nix develop github:UlyssesZh/LabJackPython-flake
```

or [`nix-shell`](https://nixos.org/manual/nix/stable/command-ref/nix-shell.html):

```shell
nix-shell --expr 'import "${fetchTarball https://github.com/UlyssesZh/LabJackPython-flake/archive/master.tar.gz}/shell.nix"'
```

Now, try using it:

```shell
python -c 'import LabJackPython; print(LabJackPython.GetDriverVersion())'
```

You may also add this flake as a dependency of other flakes.

## Udev rules

You may find adding udev rules by this snippet useful:

```nix
{ pkgs, ... }: let
  exodriver-flake = import (fetchTarball https://github.com/UlyssesZh/exodriver-flake/archive/master.tar.gz);
in {
  # ...
  services.udev.packages = [ exodriver-flake.packages.${pkgs.system}.exodriver ];
}
```

## License

MIT.

The upstream exodriver is also MIT.
See its source codes [here](https://github.com/labjack/LabJackPython).
