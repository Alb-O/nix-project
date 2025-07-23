**Instructions for an AI Coding Agent: NixOS, Flakes, and Home-Manager**

1. **Always Research First**
   - Before making changes, use the latest official documentation and community resources.
   - Use the `fetch_webpage` and `github_repo` tools to gather up-to-date information, templates, and best practices for NixOS, flakes, and home-manager.
   - Recursively follow and fetch all relevant links until you have complete context.

2. **NixOS and Flake Best Practices**
   - Use flakes for reproducible, version-pinned configurations.
   - Structure flake.nix with `description`, `inputs`, `outputs`, and (optionally) `nixConfig`.
   - Use the `outputs` function to define `nixosConfigurations`, `packages`, `apps`, `devShells`, and overlays.
   - Pass `specialArgs` to modules for flake input access.
   - Never store secrets in flake files; use a secrets manager.
   - Enable flakes in your system config:  
     `nix.settings.experimental-features = [ "nix-command" "flakes" ];`
   - Use overlays and multiple channels as needed, following official patterns.
   - Prefer pure evaluation: avoid `builtins.currentSystem`, use explicit `system` arguments, and always provide hashes for fetchers.

3. **Home-Manager Best Practices**
   - Use home-manager as a NixOS module or standalone, but prefer the module for full integration.
   - Store user config in `home.nix` or as part of your flake.
   - Use `home.packages` for declarative package management.
   - Manage dotfiles and program configs using home-manager options or `xdg.configFile`/`home.file`.
   - Always set `home.stateVersion`.
   - For non-NixOS, enable `targets.genericLinux.enable = true;`.
   - After changes, run `nixos-rebuild switch` (as root) or `home-manager switch` (as user).

4. **Prompt Engineering and Agent Behavior**
   - Use clear, step-by-step reasoning and chain-of-thought prompting.
   - Break down tasks into a todo list and check off each step as you complete it.
   - Always verify changes by running or simulating builds and checking for errors.
   - If you encounter errors or ambiguity, research further before proceeding.
   - Prefer minimal, functional, and idiomatic Nix code. Use community templates as a starting point.
   - Document any non-obvious choices or workarounds in comments.


5. **Testing and Validation**
   - After making changes, validate your configuration using the flake-based workflow:
     - Run `./rebuild.sh <hostname>` to build, checkpoint, and deploy your NixOS configuration.
     - This script will handle git commits and branch management automatically.
   - For home-manager as a NixOS module, configuration is applied as part of the system rebuild.
   - For standalone home-manager, use `home-manager switch --flake .#<username>@<hostname>` if configured, or follow your flake's documented invocation.
   - Always check for errors after switching or rebuilding.
   - If possible, add or update tests for custom modules or packages.

---

**References:**
- [NixOS Flakes Wiki](https://nixos.wiki/wiki/Flakes)
- [Home Manager Wiki](https://nixos.wiki/wiki/Home_Manager)
- [NixOS & Flakes Book](https://github.com/ryan4yin/nixos-and-flakes-book)
- [Home Manager Options](https://nix-community.github.io/home-manager/options.xhtml)