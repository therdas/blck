blck.std.true_string.len() {
  set -o localoptions -o extendedglob
  set -o localoptions -o ksh_glob
  local stripped="${1//\%[FKfkBb](\{?(\#)[^\}]#\})#/}"
  local expanded=$(print -P "$stripped")
  echo "${#expanded}"
}

blck.std.true_string.convert() {
  set -o localoptions -o extendedglob
  set -o localoptions -o ksh_glob
  local stripped="${1//\%[FKfkBb](\{?(\#)[^\}]#\})#/}"
  local expanded=$(print -P "$stripped")
  echo "$stripped"
}