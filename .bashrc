# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# User specific aliases and functions

repoquery_whatrequires() {
  if [ -z "$1" ]; then
    echo "Usage: repoquery_whatrequires <package_name>"
    return 1
  fi
  sudo dnf repoquery --whatrequires "$1" --recursive --qf "%{name} from %{repoid}"
}

add_repo() {
  if [ -z "$1" ]; then
    echo "Usage: add_repo <path to the container>"
    return 1
  fi
  sudo dnf config-manager --add-repo "$1"
}
