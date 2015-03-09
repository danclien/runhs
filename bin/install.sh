#!/bin/sh

# Utility functions

## Logging
log_info() {
  echo "$(tput setaf 6)Info:   $(tput sgr 0)" "$@"
}

log_warning() {
  echo "$(tput setaf 3)Warning:$(tput sgr 0)" "$@"
}

log_success() {
  echo "$(tput setaf 2)Success:$(tput sgr 0)" "$@"
}

log_error() {
  echo "$(tput setaf 1)Error:  $(tput sgr 0)" "$@" 1>&2
}

## Command
assert_installed() {
  command -v "$1" >/dev/null
  if [ $? -ne 0 ]; then
    log_error "$2" "not installed."
    exit 1
  fi
}

# `runsh`

## Assert $HOME is set
assert_home() {
  if [ -z "$HOME" ]; then
    log_error "HOME environment variable is not set."
    exit 4
  fi
}

## Get the installation directory
get_install_dir() {
  if [ -z "$RUNHS_DIR" ]; then
    log_info "RUNHS_DIR not set. Using default install location."
    assert_home
  fi

  runhs_dir=${RUNHS_DIR:-$HOME/.runhs}

  log_info "Installing to ${runhs_dir}."
}

assert_install_dir_is_empty() {
  if [ -d "$runhs_dir" ]; then
    log_error "Installation directory ${runhs_dir} already exists."
    exit 5
  fi
}

clone_runhs() {
  log_info "Cloning runhs Git repository to $runhs_dir"

  git clone https://github.com/danclien/runhs "$runhs_dir"
  if [ $? -ne 0 ]; then
    log_error "Git clone failed."
    exit 6
  fi
}

build_sandbox() {
  log_info "Building sandbox."

  cd "$runhs_dir"
  cabal sandbox init
  if [ $? -ne 0 ]; then
    log_error "Failed to initialize sandbox."
    exit 7
  fi

  cabal install
  if [ $? -ne 0 ]; then
    log_error "Failed to install packages into sandbox."
    exit 8
  fi
}

create_runhs_dir() {
  mkdir -p "$runhs_dir"/bin
  if [ $? -ne 0 ]; then
    log_error "Failed to create $runhs_dir/bin."
    exit 9
  fi
}

get_runhs_file() {
  runhs_file=$runhs_dir/bin/runhs
}

assert_runhs_does_not_exist() {
  if [ -f "$runhs_file" ]; then
    log_error "$runhs_file already exists."
    exit 10
  fi
}

get_package_db() {
  package_db="$(find "$runhs_dir"/.cabal-sandbox -type d -name "*packages.conf.d" | head -n1)"
  log_info "Using $package_db for -package-db."
}

create_runhs_script() {
  log_info "Creating $runhs_file script."

  cat << EOF > $runhs_file
#!/bin/sh
runhaskell -no-user-package-db -package-db=${package_db} "\$@"
EOF

  if [ $? -ne 0 ]; then
    log_error "Failed to create $runhs_file."
    exit 11
  fi
}

make_runhs_executable() {
  log_info "Making $runhs_file executable."

  chmod +x "$runhs_file"
  if [ $? -ne 0 ]; then
    log_error "Failed to make $runhs_file executable."
    exit 12
  fi
}

usage() {
  log_success "runhs installed successfully."
  log_warning "Additional steps must be taken to before use."
cat << EOF

To use runhs, add $runhs_dir/bin to your PATH.

You use runhs by adding the following to the top of your Haskell script file:

  #!/usr/bin/env runhs

Example:

  #!/usr/bin/env runhs

  {-# LANGUAGE OverloadedStrings #-}

  import Turtle

  main = echo "Hello, world!"

EOF
}

assert_installed runhaskell "Haskell (runhaskell)"
assert_installed cabal "Cabal"
assert_installed git "Git"
get_install_dir
assert_install_dir_is_empty
clone_runhs
build_sandbox
create_runhs_dir
get_runhs_file
assert_runhs_does_not_exist
get_package_db
create_runhs_script
make_runhs_executable
usage
