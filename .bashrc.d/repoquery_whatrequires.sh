repoquery_whatrequires() {
  if [ -z "$1" ]; then
    echo "Usage: repoquery_whatrequires <package_name>"
    return 1
  fi
  sudo dnf repoquery --whatrequires "$1" --recursive --qf "%{name} from %{repoid}"
}