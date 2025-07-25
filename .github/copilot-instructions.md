You have access to a variety of tools for working with Nix, NixOS, Home Manager, and Darwin configurations. Here’s a quick overview of the available commands:

### NixOS Tools
- `nixos_search(query, type, channel)` - Search packages, options, or programs
- `nixos_info(name, type, channel)` - Get detailed info about packages/options
- `nixos_stats(channel)` - Package and option counts
- `nixos_channels()` - List all available channels
- `nixos_flakes_search(query)` - Search community flakes
- `nixos_flakes_stats()` - Flake ecosystem statistics

### Version History Tools
- `nixhub_package_versions(package, limit)` - Get version history with commit hashes
- `nixhub_find_version(package, version)` - Smart search for specific versions

### Home Manager Tools
- `home_manager_search(query)` - Search user config options
- `home_manager_info(name)` - Get option details (with suggestions!)
- `home_manager_stats()` - See what's available
- `home_manager_list_options()` - Browse all 131 categories
- `home_manager_options_by_prefix(prefix)` - Explore options by prefix

### Darwin Tools
- `darwin_search(query)` - Search macOS options
- `darwin_info(name)` - Get option details
- `darwin_stats()` - macOS configuration statistics
- `darwin_list_options()` - Browse all 21 categories
- `darwin_options_by_prefix(prefix)` - Explore macOS options