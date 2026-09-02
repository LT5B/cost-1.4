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
