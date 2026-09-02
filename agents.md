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
