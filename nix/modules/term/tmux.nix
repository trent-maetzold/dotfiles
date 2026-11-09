{ pkgs, ... }:
{
  programs.tmux = {
    enable = true;
    shell = "${pkgs.nushell}/bin/nu";
    terminal = "tmux-256color";
    prefix = "C-b";
    baseIndex = 1;
    mouse = true;
    keyMode = "vi";
    customPaneNavigationAndResize = true;
    focusEvents = true;
    escapeTime = 10;
    historyLimit = 50000;
    clock24 = true;
    sensibleOnTop = true;

    extraConfig = ''
      set -g renumber-windows on
      set -g set-clipboard on
      set -g allow-passthrough on
      set -as terminal-features ',xterm*:RGB,screen*:RGB,tmux*:RGB'

      # Herdr bindings: tmux windows are tabs, sessions are workspaces.
      bind v split-window -h -c '#{pane_current_path}'
      bind - split-window -v -c '#{pane_current_path}'
      bind c new-window -c '#{pane_current_path}'
      bind T command-prompt -I '#W' 'rename-window "%%"'
      bind p previous-window
      bind n next-window
      bind X confirm-before -p 'Close tab? (y/n)' kill-window
      bind P command-prompt -I '#{pane_title}' 'select-pane -T "%%"'
      bind Tab select-pane -t :.+
      bind BTab select-pane -t :.-
      bind x confirm-before -p 'Close pane? (y/n)' kill-pane
      bind z resize-pane -Z
      bind q detach-client
      bind w choose-tree -s
      bind N command-prompt -p 'New workspace:' 'new-session -s "%%" -c "#{pane_current_path}"'
      bind W command-prompt -I '#S' 'rename-session "%%"'
      bind D confirm-before -p 'Close workspace? (y/n)' kill-session
      bind R source-file ~/.config/tmux/tmux.conf \; display-message 'Config reloaded'

      # Prefix + r enters resize mode; hjkl/arrows resize until Enter/Escape.
      bind r switch-client -T resize
      bind -T resize h resize-pane -L 5 \; switch-client -T resize
      bind -T resize j resize-pane -D 5 \; switch-client -T resize
      bind -T resize k resize-pane -U 5 \; switch-client -T resize
      bind -T resize l resize-pane -R 5 \; switch-client -T resize
      bind -T resize Left resize-pane -L 5 \; switch-client -T resize
      bind -T resize Down resize-pane -D 5 \; switch-client -T resize
      bind -T resize Up resize-pane -U 5 \; switch-client -T resize
      bind -T resize Right resize-pane -R 5 \; switch-client -T resize
      bind -T resize Enter switch-client -T root
      bind -T resize Escape switch-client -T root

      # Prefix + [ enters copy mode; v selects, y copies using OSC 52.
      bind -T copy-mode-vi v send-keys -X begin-selection
      bind -T copy-mode-vi y send-keys -X copy-selection-and-cancel
      bind -T copy-mode-vi Escape send-keys -X cancel

      # Quiet status line; no plugins or automatic session attachment.
      set -g status-interval 5
      set -g status-style 'bg=colour235,fg=colour250'
      set -g status-left '#[fg=colour111,bold] #S #[default]'
      set -g status-left-length 30
      set -g status-right '#[fg=colour244]%Y-%m-%d %H:%M '
      setw -g window-status-format ' #I:#W '
      setw -g window-status-current-format '#[fg=colour111,bold] #I:#W #[default]'
      set -g pane-border-style 'fg=colour238'
      set -g pane-active-border-style 'fg=colour111'
    '';
  };
}
