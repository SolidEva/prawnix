{ pkgs, ... }:

{

  programs.fish = {
    enable = true;
    interactiveShellInit = ''
        function sst
          ssh -t $argv "tmux a || tmux"
        end
        set -g fish_greeting ""
      '';
  };

  # fish cant be our login shell, since it makes systemd recovery mode and other things like that
  # puke (TODO: test & confirm that we actually still need this)
  users.defaultUserShell = pkgs.bash;
  programs.bash = {
    interactiveShellInit = ''
      # "check if parent process is not fish" && "make nested shells work properly"
      if grep -qv "fish\|nix-shell" /proc/$PPID/comm && [[ $SHLVL == [12] ]]; then
          # set $SHELL for better integration with programs like nix shell, tmux, etc.
          SHELL=${pkgs.fish}/bin/fish exec fish
      fi
    '';
  };

  # okay, ~one~ two plugins. nothing crazy
  environment.systemPackages = [
    pkgs.fishPlugins.bass # wrap bash commands with fish
    pkgs.fishPlugins.hydro # simple prompt
  ];
}
