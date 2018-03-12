## Development

```
$ nix-shell
$ bin/github-to-irc config.json
```

## Using

```
$ nix-build
$ result/bin/github-to-irc config.json
```

## Updating gems

```
$ bundle install --path=vendor/bundle             # Ensures lockfile is updated
$ $(nix-build '<nixpkgs>' -A bundix)/bin/bundix   # Updates gemset
```

## Configuration

`per-channel` configuration will take *lower-cased* "fully-qualified" repo names, e.g. `NixOS/ofborg` → `nixos/ofborg`.
