#!stateconf yaml . jinja
#
# ZSH Installation w/ Oh-My-Zsh
#


bruno:
  user.present:
    - fullname: Bruno Vernay
    - shell: /bin/zsh
    - password: $6$Ua9C9O6iHjg75BB8$ureWAPD1yZinF2hOgsuFK3WpLntwJxXgEd733GPjYIqn9jFSKlyT63XsKqPVO86MtX8y/v/hU1hdytn.RLZtM0
    - groups:
      - wheel
      - users


.git:
  pkg:
    - installed

# Install ZShell

.zsh:
  pkg:
    - installed

# Set ZSH as default shell

.default_shell:
  cmd:
    - run
    - name: "chsh -s /usr/bin/zsh vagrant"
    - unless: "grep -E '^vagrant.+:/usr/bin/zsh$' /etc/passwd"
    - require:
      - pkg: .zsh