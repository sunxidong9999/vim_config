# vim_config

A shell script for vim configuration for CentOS/RedHat/Debian/Ubuntu/Kylin.

Usage:
  `./vim_config.sh <options> <parameters>`

Options:
  `-g <proxy>`: specify github proxy (e.g. -g https://ghp.ci)
  `-u <username>`: specify username that shows in file title
  `-e <user's email>`: specify user's email address that shows in file title
  `-h`: Show this usage message

e.g.:
  `./vim_config.sh -u SunXidong -e admin@example.com`

It will install universal-ctags and cscope, some vim plugins such as nerdtree, tagbar, vim-multiple-cursors etc.

C and Golang supported
