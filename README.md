cpupower bash completion script
===============================

Bash completion script for the `cpupower` utility.


Installation
============

1. Create the file `.bash_completion` in your `$HOME` directory.
2. Add the following lines to source the script:
`. /path/to/cpupower-bash-completion.sh`


Incomplete stuff
================
* Support the `idle-info` command arguments (if any, there are no man page for it).
* Currently only these arguments values are supported for autocomplete:
	* `frequency-set -g`
	* `-c`

