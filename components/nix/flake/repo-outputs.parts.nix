{ config, ... }: {
  # Expose lib from repo on flake.
  flake.lib = config.repo.lib;
}
