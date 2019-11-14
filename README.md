## Development

```
$ nix-shell
$ bin/dev-setup
$ bin/github-to-irc config.json
```

## Using

```
$ nix-build
$ result/bin/github-to-irc config.json
```

## Updating gems

Updating gems:

```
$ nix-shell -p bundler
$ bundle install --path=vendor/bundle # Ensures local gems path is used
$ bundle update                       # Updates gems
```

Locking gems for bundix:

```
$ bundle install --path=vendor/bundle             # Ensures lockfile is updated
$ $(nix-build '<nixpkgs>' -A bundix)/bin/bundix   # Updates gemset
```

## Configuration

`per-channel` configuration will take *lower-cased* "fully-qualified" repo names, e.g. `NixOS/ofborg` → `nixos/ofborg`.
