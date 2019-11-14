## Development

Use `config.example.json` as a starting point to create a `config.json`.

In a first shell

```
# Start a development rabbitmq instance
$ nix-shell --run start-services
```

Then, in a second shell

```
$ nix-shell

# Create the minimal "test" environment on the rabbitmq server
$ bin/dev-setup config.json

# Run the service
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
