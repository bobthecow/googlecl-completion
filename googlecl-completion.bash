#!bash
#
# googlecl-completion
# ===================
# 
# Bash completion support for googlecl
# 
# 
# Installation
# ------------
# 
#  1. Install this file. Either:
# 
#     a. Place it in a `bash-completion.d` folder:
# 
#        * /etc/bash-completion.d
#        * /usr/local/etc/bash-completion.d
#        * ~/bash-completion.d
# 
#     b. Or, copy it somewhere (e.g. ~/.googlecl-completion.bash) and put the following line in
#        your .bashrc:
# 
#            source ~/.googlecl-completion.bash
# 
# 
# 
# The Fine Print
# --------------
# 
# Copyright (c) 2010 [Justin Hileman](http://justinhileman.com)
# 
# Distributed under the [MIT License](http://creativecommons.org/licenses/MIT/)


__googleclcomp_1 ()
{
	local c IFS=' '$'\t'$'\n'
	for c in $1; do
		case "$c$2" in
		--*=*) printf %s$'\n' "$c$2" ;;
		*.)    printf %s$'\n' "$c$2" ;;
		*)     printf %s$'\n' "$c$2 " ;;
		esac
	done
}
__googleclcomp ()
{
	local cur="${COMP_WORDS[COMP_CWORD]}"
	if [ $# -gt 2 ]; then
		cur="$3"
	fi
	case "$cur" in
	--*=)
		COMPREPLY=()
		;;
	*)
		local IFS=$'\n'
		COMPREPLY=($(compgen -P "${2-}" \
			-W "$(__googleclcomp_1 "${1-}" "${4-}")" \
			-- "$cur"))
		;;
	esac
}

__googlecl_find_on_cmdline ()
{
	local word subcommand c=1

	while [ $c -lt $COMP_CWORD ]; do
		word="${COMP_WORDS[c]}"
		for subcommand in $1; do
			if [ "$subcommand" = "$word" ]; then
				echo "$subcommand"
				return
			fi
		done
		c=$((++c))
	done
}
__googlecl_calendar_list ()
{
	google calendar list title 2> /dev/null
}
__googlecl_calendar_today ()
{
	google calendar today title 2> /dev/null
}
__googlecl_calendar ()
{
	local subcommands="add list today delete"
	local subcommand="$(__googlecl_find_on_cmdline "$subcommands")"
	if [ -z "$subcommand" ]; then
		__googleclcomp "$subcommands"
		return
	fi

	case "$subcommand" in
	add)
		__googleclcomp "--cal"
		return
		;;
	list)
		__googleclcomp "title url --title --query --date --cal"
		return
		;;
	today)
		__googleclcomp "title url $(__googlecl_calendar_today) $(__googlecl_calendar_list)"
		return
		;;
	delete)
		__googleclcomp "$(__googlecl_calendar_today) $(__googlecl_calendar_list)"
		return
		;;
	*)
		COMPREPLY=()
		;;
	esac
}

__googlecl_docs_list ()
{
	google docs list title | sort | uniq 2> /dev/null
}
__googlecl_docs ()
{
	local subcommands="edit delete list upload get"
	local subcommand="$(__googlecl_find_on_cmdline "$subcommands")"
	if [ -z "$subcommand" ]; then
		__googleclcomp "$subcommands"
		return
	fi

	case "$subcommand" in
	edit)
#		__googleclcomp "--title --format --editor $(__googlecl_docs_list)"
		__googleclcomp "--title --format --editor"
		return
		;;
	list)
		__googleclcomp "title url --title --folder"
		return
		;;
#	upload)
#		__googleclcomp "--title --folder --no-convert $"
#		return
#		;;
	get|delete)
#		__googleclcomp "$(__googlecl_docs_list)"
		__googleclcomp "--title --folder"
		return
		;;
	*)
		COMPREPLY=()
		;;
	esac
}

_googlecl ()
{
	local subcommands="help picasa blogger youtube docs contacts calendar"
	local subcommand="$(__googlecl_find_on_cmdline "$subcommands")"
	if [ -z "$subcommand" ]; then
		__googleclcomp "$subcommands"
		return
	fi
	
	case "$subcommand" in
	picasa)
		__googleclcomp "get create list list-albums tag post delete"
		return
		;;
	blogger)
		__googleclcomp "post tag list delete"
		return
		;;
	youtube)
		__googleclcomp "post tag list delete"
		return
		;;
	docs)
		__googlecl_docs
		return
		;;
	contacts)
		__googleclcomp "add list delete"
		return
		;;
	calendar)
		__googlecl_calendar
		return
		;;
	help)
		__googleclcomp "picasa blogger youtube docs contacts calendar"
		return
		;;
	*)
		COMPREPLY=( $(compgen -f ${cur}) )
		return 0
		;;
	esac
}

complete -o bashdefault -o default -o nospace -F _googlecl google 2>/dev/null \
	|| complete -o default -o nospace -F _googlecl google
