
## Updating gems

```
$ bundle install --path=vendor/bundle             # Ensures lockfile is updated
$ $(nix-build '<nixpkgs>' -A bundix)/bin/bundix   # Updates gemset
```
