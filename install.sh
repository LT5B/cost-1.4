#!/bin/bash

echo "==> Creating directories..."
sudo mkdir -p "/opt/cost"
sudo mkdir -p "/opt/cost/bin"
sudo mkdir -p "/opt/cost/doc"
sudo mkdir -p "/opt/cost/library"
sudo mkdir -p "/opt/cost/packages"
sudo mkdir -p "/opt/cost/ruby"
sudo mkdir -p "/opt/cost/cellar"
sudo mkdir -p "/opt/cost/flag"
sudo mkdir -p "/opt/cost/applications"

# Fix Permission: Grant ownership of the /opt/cost directory to the current user
sudo chown -R $USER "/opt/cost"
sleep 1

echo "==> Downloading and compiling Git from source (no external packages)..."
cd /tmp
curl -sL -O https://www.kernel.org/pub/software/scm/git/git-2.55.0.tar.gz
tar zxf git-2.55.0.tar.gz
cd git-2.55.0
./configure
make 2>/dev/null
sudo make install 2>/dev/null
rm -rf /tmp/git-2.55.0*
sleep 1

echo "==> Creating the main executable..."
cat << 'EOF' > "/opt/cost/bin/cost"
#!/bin/bash

if [ -z "$1" ]; then
    echo "Run 'cost help' to see usage information."
    exit 1
fi

if [ ! -f "/opt/cost/flag/$1" ]; then
    echo "Cost: Command not found: cost $1"
    exit 1
else
    bash "/opt/cost/flag/$1" "${@:2}"
fi
EOF
sleep 1

echo "==> Creating command flags..."
cat << 'EOF' > "/opt/cost/flag/install"
#!/bin/bash

if [ -z "$1" ]; then
    echo "Usage: cost install <package>"
    exit 1
fi

PACKAGE_FILE="/opt/cost/packages/$1.cellar"

if [ ! -f "$PACKAGE_FILE" ]; then
    echo "Cost: Package config not found: $1"
    exit 1
fi

echo "==> Installing $1..."
# Source the package configuration to load variables safely
source "$PACKAGE_FILE"

if [ -z "$REPOSITORY" ]; then
    echo "Cost: Repository URL is missing in package configuration."
    exit 1
fi

case "$TYPE" in
    "Formula"|"Formulae"|"Package")
        if [[ "$OSTYPE" == "darwin"* ]]; then
            case "$MacOS" in
                "True"|"Yes")
                    git clone -q "$REPOSITORY" "$HOME/$1"
                    cp -r "$HOME/$1" "/opt/cost/cellar/$1"
                    rm -rf "$HOME/$1"
                    chmod -R +x "/opt/cost/cellar/$1/bin"
                    echo 'export PATH="$PATH:/opt/cost/bin"' >> "$HOME/.bashrc"
                    echo 'export PATH="$PATH:/opt/cost/bin"' >> "$HOME/.zshrc"
                    [ -f "$HOME/.zshrc" ] && source "$HOME/.zshrc"
                    [ -f "$HOME/.bashrc" ] && source "$HOME/.bashrc"
                    ;;
                "False"|"No")
                    echo "Cost: This package is not supported on macOS."
                    exit 1
                    ;;
                *)
                    echo "Cost: Cannot install this package."
                    exit 1
                    ;;
            esac
        else
            case "$Linux" in
                "True"|"Yes")
                    git clone -q "$REPOSITORY" "$HOME/$1"
                    cp -r "$HOME/$1" "/opt/cost/cellar/$1"
                    rm -rf "$HOME/$1"
                    chmod -R +x "/opt/cost/cellar/$1/bin"
                    echo 'export PATH="$PATH:/opt/cost/bin"' >> "$HOME/.bashrc"
                    [ -f "$HOME/.bashrc" ] && source "$HOME/.bashrc"
                    ;;
                "False"|"No")
                    echo "Cost: This package is not supported on Linux."
                    exit 1
                    ;;
                *)
                    echo "Cost: Cannot install this package."
                    exit 1
                    ;;
            esac
        fi
        ;;
    "Application"|"App"|"Apps"|"Applications")
        if [[ "$OSTYPE" == "darwin"* ]]; then
            case "$MacOS" in
                "True"|"Yes")
                    git clone -q "$REPOSITORY" "$HOME/$1"
                    cp -r "$HOME/$1" "/opt/cost/cellar/$1"
                    zip -r "/opt/cost/cellar/$1.zip" "/opt/cost/cellar/$1"
                    cp "/opt/cost/cellar/$1.zip" "/opt/cost/applications/$1.app"
                    rm "/opt/cost/cellar/$1.zip"
                    rm -rf "$HOME/$1"
                    chmod -R +x "/opt/cost/cellar/$1/bin"
                    echo 'export PATH="$PATH:/opt/cost/bin"' >> "$HOME/.bashrc"
                    echo 'export PATH="$PATH:/opt/cost/bin"' >> "$HOME/.zshrc"
                    ;;
                "False"|"No")
                    echo "Cost: This application is not supported on macOS."
                    exit 1
                    ;;
                *)
                    echo "Cost: Cannot install this application."
                    exit 1
                    ;;
            esac
        else
            case "$Linux" in
                "True"|"Yes")
                    git clone -q "$REPOSITORY" "$HOME/$1"
                    cp -r "$HOME/$1" "/opt/cost/cellar/$1"
                    zip -r "/opt/cost/cellar/$1.zip" "/opt/cost/cellar/$1"
                    cp "/opt/cost/cellar/$1.zip" "/opt/cost/applications/$1.darwin"
                    rm "/opt/cost/cellar/$1.zip"
                    rm -rf "$HOME/$1"
                    chmod -R +x "/opt/cost/cellar/$1/bin"
                    echo 'export PATH="$PATH:/opt/cost/bin"' >> "$HOME/.bashrc"
                    [ -f "$HOME/.bashrc" ] && source "$HOME/.bashrc"
                    ;;
                "False"|"No")
                    echo "Cost: This application is not supported on Linux."
                    exit 1
                    ;;
                *)
                    echo "Cost: Cannot install this application."
                    exit 1
                    ;;
            esac
        fi
        ;;
    *)
        echo "Cost: Unknown package type: $TYPE"
        exit 1
        ;;
esac

echo "export PATH=\"\$PATH:/opt/cost/cellar/$1\"" >> "$HOME/.bashrc"
echo "export PATH=\"\$PATH:/opt/cost/cellar/$1\"" >> "$HOME/.zshrc"

[ -f "$HOME/.bashrc" ] && source "$HOME/.bashrc"
[ -f "$HOME/.zshrc" ] && source "$HOME/.zshrc"
echo "==> Successfully installed $1!"
EOF

cat << 'EOF' > "/opt/cost/flag/uninstall"
#!/bin/bash

if [ -z "$1" ]; then
    echo "Usage: cost uninstall <package>"
    exit 1
fi

if [ -d "/opt/cost/cellar/$1" ]; then
    sudo rm -rf "/opt/cost/cellar/$1"
    echo "Cost: Removed package $1"
else
    echo "Cost: Package not found in cellar: $1"
    exit 1
fi
EOF

cat << 'EOF' > "/opt/cost/flag/license"
#!/bin/bash
cat "/opt/cost/doc/license.md"
EOF

cat << 'EOF' > "/opt/cost/flag/readme"
#!/bin/bash
cat "/opt/cost/doc/readme.md"
EOF

cat << 'EOF' > "/opt/cost/flag/help"
#!/bin/bash
cat "/opt/cost/doc/help.md"
EOF

cat << 'EOF' > "/opt/cost/flag/owner"
#!/bin/bash
cat "/opt/cost/doc/owner"
EOF

cat << 'EOF' > "/opt/cost/flag/owner-email"
#!/bin/bash
cat "/opt/cost/doc/owner-email"
EOF

cat << 'EOF' > "/opt/cost/flag/info"
#!/bin/bash

if [ -z "$1" ]; then
    echo "Usage: cost info <package>"
    exit 1
fi

if [ -f "/opt/cost/packages/$1.cellar" ]; then
    cat "/opt/cost/packages/$1.cellar"
else
    echo "Cost: Package not found: $1"
    exit 1
fi
EOF

cat << 'EOF' > "/opt/cost/flag/create"
#!/bin/bash

read -p "Name: " name
read -p "Author: " author
read -p "Type: " type
read -p "Supported on macOS (True/False): " darwin
read -p "Supported on Linux (True/False): " linux
read -p "Repository URL: " REPOSITORY

cat << EOS > "/opt/cost/library/$name.cellar"
NAME="$name"
AUTHOR="$author"
TYPE="$type"
MacOS="$darwin"
Linux="$linux"
REPOSITORY="$REPOSITORY"
EOS

EOF

cat << 'EOF' > "/opt/cost/flag/publish"
#!/bin/bash

ruby "/opt/cost/ruby/publish.rb"
EOF

cat << 'EOF' > "/opt/cost/flag/delete-project"
#!/bin/bash

if [ -z "$1" ]; then
    echo "Usage: cost delete-project <your-package>"
    exit 1
fi

if [ -f "/opt/cost/library/$1" ]; then
    rm "/opt/cost/library/$1"
else
    echo "Cost: Package not found: $1"
    exit 1
fi
EOF

cat << 'EOF' > "/opt/cost/flag/search"
#!/bin/bash
find "/opt/cost/packages" -type f | while read -r filepath; do
    basename="${filepath%.*}"
    echo "cost install:"
    echo "$basename"
done
EOF

cat << 'EOF' > "/opt/cost/flag/agents"
#!/bin/bash
cat "/opt/cost/doc/agents.md"
EOF

cat << 'EOF' > "/opt/cost/flag/manual"
#!/bin/bash
cat "/opt/cost/doc/manual.md"
EOF

cat << 'EOF' > "/opt/cost/flag/version"
#!/bin/bash
cat "/opt/cost/doc/version.md"
EOF

cat << 'EOF' > "/opt/cost/flag/copyright"
#!/bin/bash
cat "/opt/cost/doc/copyright.md"
EOF

cat << 'EOF' > "/opt/cost/flag/set-version"
#!/bin/bash

if [ -z "$1" ]; then
    echo "Usage: cost set-version <version>"
    exit 1
fi

sudo rm -rf "/opt/cost"
git clone -q https://github.com/LT5B/cost-${1}
cd cost-$1
sudo ./install.sh
EOF

cat << 'EOF' > "/opt/cost/flag/sync"
#!/bin/bash
ruby "/opt/cost/ruby/sync.rb"
EOF

sleep 1
echo "==> Creating documentation..."
cat << 'EOF' > "/opt/cost/doc/license.md"
# COST LICENSE

Copyright (c) 2026 LT5B

## 1. Permission

Permission is hereby granted, free of charge, to any person obtaining a copy of the `cost` Bash package and associated files (the "Software"), to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, subject to the conditions stated in this License.

## 2. Conditions

The following conditions apply:

* The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
* Modified versions of the Software must clearly indicate that changes have been made.
* The name "LT5B" shall not be used to endorse or promote products derived from the Software without prior written permission.

## 3. Disclaimer

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, AND NON-INFRINGEMENT.

IN NO EVENT SHALL LT5B BE LIABLE FOR ANY CLAIM, DAMAGES, OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT, OR OTHERWISE, ARISING FROM, OUT OF, OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

## 4. Attribution

When the Software is redistributed or included in another project, reasonable attribution to **LT5B** and the `cost` Bash package is appreciated.

## 5. License Version

This license is the **COST License, Version 1.0**, created for the `cost` Bash package by **LT5B**.

Copyright (c) 2026 LT5B. All rights reserved.
EOF

cat << 'EOF' > "/opt/cost/doc/readme.md"
Cost

Cost is a Bash-based package management script designed to provide a simple and lightweight way to manage software packages directly from the command line.

Created by LT5B.

Features
📦 Simple package management
⚡ Lightweight Bash implementation
🖥️ Command-line interface
🔍 Search for available packages
📥 Install packages
🗑️ Remove packages
🔄 Update packages
📋 View package information
🧩 Designed to be easy to extend
🐧 Built for Unix-like environments

Philosophy

Cost is designed around three principles:

Simplicity
Package management should not require complicated commands.
Lightweight Design
Cost is implemented as a Bash script, keeping the project small and easy to inspect.
Ease of Use
Commands should be understandable and predictable for users.
Requirements

Cost requires:

Bash
A Unix-like operating system
Standard command-line utilities

Version

Current Project: Cost
Language: Bash
Creator: LT5B

Author

LT5B

Cost is an independent Bash project created to make package management more accessible through a simple command-line experience.

Cost — Simple package management, powered by Bash.
EOF

cat << 'EOF' > "/opt/cost/doc/help.md"
# COST HELP

Cost is a lightweight Bash package manager.

## Available Commands:
- cost install <package>    : Install a package
- cost uninstall <package>  : Remove an installed package
- cost search               : Search available packages
- cost info <package>       : Show package details
- cost create               : Create a new local package config
- cost publish              : Publish a package to repository
- cost delete-project <pkg> : Remove project file
- cost sync                 : Sync packages between users
- cost set-version <ver>    : Switch/update cost version
- cost readme               : Show project readme
- cost license              : Show project license
- cost manual               : Show full manual
- cost version              : Show version information
- cost copyright            : Show copyright notices
- cost owner                : Show author name
- cost owner-email          : Show author contact email
- cost agents               : Show project architectural guidelines
EOF

cat << 'EOF' > "/opt/cost/doc/agents.md"
Project: Cost

Cost is a Bash-based package manager designed to install and manage programming languages, applications, and other supported packages.

Author: LT5B

1. Project Goals

When contributing to Cost:

Keep the project lightweight and Bash-friendly.
Make commands easy to understand and use.
Prioritize reliability and safety.
Avoid unnecessary dependencies.
Keep behavior predictable across supported Unix-like systems.
Preserve backward compatibility whenever possible.

2. Repository Structure

A typical Cost repository may use a structure similar to:

opt
 |
cost-|_doc
     |  |_agents.md
     |  |_readme.md
     |  |_license.md
     |  |_manual.md
     |  |_owner.md
     |  |_owner-email.md
     |  |_help.md
     |  |_copyright.md
     |  |_version.md
     |
     |_bin
     |  |_cost
     |
     |_flag
     |  |_install
     |  |_uninstall
     |  |_create
     |  |_remove-project
     |  |_agents
     |  |_readme
     |  |_license
     |  |_search
     |  |_info
     |  |_copyright
     |  |_version
     |  |_set-version
     |  |_sync
     |
     |_ruby
     |  |_sync.rb
     |  |_publish.rb
     |
     |_library
     |  |_<your-packages-here>
     |
     |_packages
     |  |_<all-packages-here>
     |
     |_cellar
     |  |_<installed-packages-here>
     |
     |_application
        |_<installed-applications-here>

The exact structure may change as the project evolves.

3. Bash Requirements

All executable Cost scripts should:

Use Bash where Bash-specific functionality is required.
Start with:
#!/bin/bash
Quote variables when appropriate.
Check important command failures.
Avoid unnecessary use of eval.
Avoid silently ignoring errors.
Use meaningful variable names.
Keep functions reasonably small and focused.

Do not introduce Bash syntax that is incompatible with the project's supported Bash versions without a good reason.

4. Command Compatibility

Existing Cost commands should not be changed unnecessarily.

Before changing command behavior:

Check existing documentation.
Check existing tests.
Consider backward compatibility.
Update documentation if behavior changes.
Add or update tests.

New commands should follow the existing command naming conventions.

5. Documentation

When a feature changes user-visible behavior, update the appropriate documentation.

Documentation may include:

README.md
Command manuals.
Package documentation.
Examples.
Configuration documentation.
Changelogs.

Do not document functionality that does not actually exist.

6. Dependencies

Cost should minimize external dependencies.

Before adding a dependency:

Determine whether Bash can perform the task itself.
Check whether a standard Unix utility already provides the functionality.
Consider portability.
Document the dependency.

Do not add large dependencies for simple tasks.

7. Changes and Pull Requests

Contributors should keep changes focused.

A change should generally:

Solve one problem.
Avoid unrelated modifications.
Include tests when appropriate.
Update documentation when necessary.
Explain important implementation decisions.

Avoid mixing large refactors with unrelated feature changes.

8. Configuration and Paths

Do not assume that every system has the same filesystem layout.

If Cost uses a directory such as:

/opt/cost/

the implementation should handle permission problems gracefully.

Avoid modifying system directories unless the operation explicitly requires it.

9. Compatibility

Cost should aim to support common Unix-like environments where practical.

When adding platform-specific behavior:

Detect the platform when necessary.
Avoid assuming a specific package manager exists.
Avoid assuming a specific CPU architecture.
Provide a useful error when a platform is unsupported.

10. General Rule

When uncertain, prefer the implementation that is:

Simple → Safe → Portable → Testable → Maintainable

Cost is a package manager, not a shell-script obstacle course. Keep it understandable enough that another contributor can modify it six months later without needing an archaeological expedition through the codebase.
EOF

cat << 'EOF' > "/opt/cost/doc/owner-email.md"
engeleditorfpe@gmail.com
EOF

cat << 'EOF' > "/opt/cost/doc/owner.md"
LT5B
EOF

cat << 'EOF' > "/opt/cost/doc/manual.md"
Cost Manual
NAME

cost - A lightweight Bash package manager for installing and managing programming languages, applications, and packages.

SYNOPSIS
cost <command> [options] [package]
DESCRIPTION

Cost is a Bash-based package manager designed to provide a simple command-line interface for installing and managing software packages.

Cost can be used to install programming languages, applications, and other supported packages through a unified command.

The default package storage location is:

/opt/cost/cellar

Cost is designed to provide a simple package-management experience inspired by tools such as Homebrew and GitHub CLI.

COMMANDS
install

Install a package.

Syntax
cost install <package>
Example
cost install lua

This command downloads and installs the requested package into the Cost package directory.

uninstall

Remove an installed package.

Syntax
cost uninstall <package>
Example
cost uninstall lua

The specified package and its Cost-managed files will be removed.

search

Search for available packages.

Syntax
cost search

info

Display information about a package.

Syntax
cost info <package>

help

Display Cost command help.

Syntax
cost help
Example
cost help

PACKAGE DIRECTORY

Cost stores installed packages in its cellar directory:

/opt/cost/cellar

The directory can contain package files and package-specific installation data.

Example:

/opt/cost/
└── cellar/
    ├── lua/
    ├── python/
    └── node/

EXAMPLES
Install a programming language
cost install lua
Install multiple packages
cost install lua
cost install python
cost install node
View installed packages
cost list
Search for a package
cost search lua
Display package information
cost info lua
Remove a package
cost uninstall lua

ERRORS

If an invalid command or missing package argument is provided, Cost should display usage information.

Example:

Usage:
  cost <command> [options] [package]

For an unavailable package, Cost should report that the package could not be found.

SECURITY

Cost should only install packages from trusted package sources.

Package installation scripts should be reviewed and handled carefully because downloaded software can execute with the permissions granted to the installation process.

Users should avoid running Cost with elevated privileges unless required by the installation method.

FILES
/opt/cost/

Main Cost directory.

/opt/cost/cellar/

Package storage directory.

SEE ALSO
bash

Bourne Again SHell.

AUTHOR

LT5B

COPYRIGHT

Copyright © 2026 LT5B.

Cost is provided as a software project under its applicable license.
EOF

cat << 'EOF' > "/opt/cost/doc/copyright.md"
Copyright (C) 2026 LT5B - COST
[*] No copy
[*] No reupload
EOF

cat << 'EOF' > "/opt/cost/doc/version.md"
Cost 1.4
EOF

echo "==> Creating Ruby scripts..."
cat << 'EOF' > "/opt/cost/ruby/sync.rb"
#!/usr/bin/env ruby
require 'etc'
require 'fileutils'

cost_users = []
Etc.passwd do |user|
  next if user.dir == '/' || user.dir.start_with?('/var/') || user.dir.include?('nobody')
  
  if user.dir == '/opt/cost' || Dir.exist?(File.join(user.dir, 'opt/cost')) || user.dir.start_with?('/opt/cost')
    cost_users << user.name
  end
end

if cost_users.empty?
  puts "[-] No users found with an /opt/cost directory."
  exit 1
end

source_user = cost_users.first
source_dir = "/opt/cost/packages"

unless Dir.exist?(source_dir)
  puts "[-] Source directory #{source_dir} does not exist."
  exit 1
end

puts "[+] Source User: #{source_user}"
puts "[+] Source Directory: #{source_dir}"

all_users = []
Etc.passwd do |user|
  next if user.shell =~ /(false|nologin)/
  next if user.dir == '/' || user.dir.start_with?('/var/')
  all_users << user
end

all_users.each do |user|
  # next if user.name == source_user

  target_dir = "/opt/cost/packages"

  # target_dir = File.join(user.dir, "opt/cost/packages")

  puts "[*] Copying packages for user: #{user.name}..."
  
  begin
    FileUtils.mkdir_p(target_dir)
    
    Dir.glob("#{source_dir}/**/*").each do |item|
      next if File.directory?(item) # Directories are handled via mkdir_p or file copying
      
      rel_path = item.sub("#{source_dir}/", "")
      dest_file = File.join(target_dir, rel_path)
      
      FileUtils.mkdir_p(File.dirname(dest_file))
      FileUtils.cp_r(item, dest_file, remove_destination: true)
      
      File.chown(user.uid, user.gid, dest_file) rescue nil
    end
    puts "[+] Success: #{user.name}"
  rescue => e
    puts "[-] Error copying for #{user.name}: #{e.message}"
  end
end

puts "[+] Process completed successfully!"
EOF

cat << 'EOF' > "/opt/cost/ruby/publish.rb"
#!/usr/bin/env ruby
require 'fileutils'

TARGET_DIR = '/opt/cost/packages'

if ARGV.empty?
  print "Enter the source file path: "
  source_path = gets.chomp.strip
else
  source_path = ARGV[0].strip
end

source_path = source_path.gsub(/\A['"\s]+|['"\s]+\z/, '')

unless File.exist?(source_path)
  puts "Error: File '#{source_path}' does not exist!"
  exit 1
end

if File.directory?(source_path)
  puts "Error: This is a directory. Please provide a file path instead!"
  exit 1
end

unless Dir.exist?(TARGET_DIR)
  begin
    FileUtils.mkdir_p(TARGET_DIR)
  rescue Errno::EACCES
    puts "Error: Permission denied to create #{TARGET_DIR}. Please run with 'sudo'."
    exit 1
  end
end

begin
  filename = File.basename(source_path)
  dest_path = File.join(TARGET_DIR, filename)
  
  FileUtils.cp(source_path, dest_path)
  puts "Success: File copied to #{dest_path}"
rescue Errno::EACCES
  puts "Error: Permission denied. Please run this command as 'sudo cost'."
rescue => e
  puts "An error occurred: #{e.message}"
end
EOF

echo "==> Granting execution permissions..."
chmod +x /opt/cost/bin/cost
chmod -R +x /opt/cost/flag
echo 'export PATH="$PATH:/opt/cost/bin"' >> "$HOME/.bashrc"
echo 'export PATH="$PATH:/opt/cost/bin"' >> "$HOME/.zshrc"

[ -f "$HOME/.zshrc" ] && source "$HOME/.zshrc"
[ -f "$HOME/.bashrc" ] && source "$HOME/.bashrc"

echo "Installation complete!"
