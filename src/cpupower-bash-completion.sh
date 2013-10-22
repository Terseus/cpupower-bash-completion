## Autocompletion bash for the command 'cpupower'
## Distro: Archlinux
## Creator: Terseus <terseus gmail com>
## Date: 20-Jul-2013
## Version: 0.3
## This software is released into the public domain.


# Indicate if an item is present in an array
# Usage: in_array "$ITEM" "${ARRAY[@]}"
in_array()
{
	local ITEM
	for ITEM in "${@:2}"; do [[ "$ITEM" == "$1" ]] && return 0; done
	return 1
}

# Returns (stdout) the CPU list.
# Usage: get_cpus
get_cpus()
{
	sed -n '{s/processor[[:space:]]\+:[[:space:]]*\([0-9]\+\)/\1/p}' /proc/cpuinfo
}

_cpupower()
{
	# Global flags
	local FLAG_DEBUG=1
	local FLAG_CPU=2
	local FLAG_COMPGEN_COMMAND=4
	local FLAGS=0
	# frequency-info command flags
	local FLAG_FREQINFOSET_OUTPUT=1
	local FLAG_FREQINFOSET_HUMAN=2
	local FLAG_FREQINFOSET_PROC=4
	local FLAGS_FREQINFO=0
	# frequency-set command flags
	local FLAG_FREQSET_MIN=1
	local FLAG_FREQSET_MAX=2
	local FLAG_FREQSET_GOV=4
	local FLAG_FREQSET_FREQ=8
	local FLAG_FREQSET_RELATED=16
	local FLAGS_FREQSET=0
	# info & set command flags
	local FLAG_INFOSET_PERFBIAS=1
	local FLAG_INFOSET_SCHEDMC=2
	local FLAG_INFOSET_SCHEDSMT=4
	local FLAGS_INFOSET=0
	# monitor command flags
	local FLAG_MONITOR_LIST=1
	local FLAG_MONITOR_INTERVAL=2
	local FLAG_MONITOR_ONLY=4
	local FLAG_MONITOR_SCHED=8
	local FLAG_MONITOR_VERBOSE=16
	local FLAGS_MONITOR=0
	# States
	local STATE_BASE=0 # Initial
	local STATE_CPU_WAITING=1 # Waiting Cpu list
	local STATE_COMMAND_WAITING=2 # Waiting command argument
	local STATE_COMMAND_VALUE_WAITING=3 # Waiting command argument value
	# Current state
	local STATE=$STATE_BASE
	# Debug parameters
	local -a DEBUG_OPTS=("-d" "--debug")
	# Cpu parameters
	local -a CPU_OPTS=("-c" "--cpu")
	# Help parameters (basic help)
	local -a HELP_OPTS=("-h" "--help")
	# Show version parameters
	local -a VERSION_OPTS=("-v" "--version")
	# Commands parameters
	local -a COMMAND_OPTS=("frequency-info" "frequency-set" "idle-info" "info" "set" "monitor" "help")
	# frequency-info command parameters (output, only one allowed)
	# The -s|--stats parameter it's not an "output" parameters in the docs, but cpupower throws the error "You can't specify more than one --cpu parameter and/or more than one output-specific argument".
	local -a FREQINFOSET_OUTPUT_OPTS=("-e" "--debug" "-a" "--related-cpus" "--affected-cpus" "-g" "--governors" "-p" "--policy" "-d" "--driver" "-l" "--hwlimits" "-f" "--freq" "-y" "--latency" "-w" "--hwfreq" "-s" "--stats")
	# frequency-info individual options
	local -a FREQINFOSET_HUMAN_OPTS=("-m" "--human")
	# this frequency-info option is incompatible with the global -c|--cpu option
	local -a FREQINFOSET_PROC_OPTS=("-o" "--proc")
	# frequency-set command individual parameters
	local -a FREQSET_MIN_OPTS=("-d" "--min")
	local -a FREQSET_MAX_OPTS=("-u" "--max")
	local -a FREQSET_GOV_OPTS=("-g" "--governor")
	local -a FREQSET_FREQ_OPTS=("-f" "--freq")
	local -a FREQSET_RELATED_OPTS=("-r" "--related")
	# frequency-set -g valid values (governors)
	local -a FREQSET_GOV_VALUES=("ondemand" "performance" "conservative" "powersave" "userspace")
	# info command individual parameters
	local -a INFOSET_PERFBIAS_OPTS=("-b" "--perf-bias")
	local -a INFOSET_SCHEDMC_OPTS=("-m" "--sched-mc")
	local -a INFOSET_SCHEDSMT_OPTS=("-s" "--sched-smt")
	# monitor command individual parameters
	local -a MONITOR_LIST_OPTS=("-l")
	local -a MONITOR_INTERVAL_OPTS=("-i")
	local -a MONITOR_ONLY_OPTS=("-m")
	local -a MONITOR_SCHED_OPTS=("-c")
	local -a MONITOR_VERBOSE_OPTS=("-v")
	# CPU list
	local -a CPUS=(`get_cpus`)
	# Current word
	local CUR_WORD="${COMP_WORDS[COMP_CWORD]}"
	# Last word to process
	local -i LAST_WORD=$COMP_CWORD-1
	# 'compgen' extra arguments
	local COMPGEN_EXTRA=""
	local WORD OPTS CUR_COMMAND CUR_OPT

	for WORD in "${COMP_WORDS[@]:1:$LAST_WORD}"; do
		[ -z "$WORD" ] && continue
		case $STATE in
			$STATE_BASE)
				in_array "$WORD" "${HELP_OPTS[@]}" && return 0
				in_array "$WORD" "${VERSION_OPTS[@]}" && return 0
				if in_array "$WORD" "${DEBUG_OPTS[@]}"; then
					(( $FLAGS & $FLAG_DEBUG )) && return 1
					(( FLAGS |= $FLAG_DEBUG ))
				elif in_array "$WORD" "${CPU_OPTS[@]}"; then
					(( $FLAGS & $FLAG_CPU )) && return 1
					STATE=$STATE_CPU_WAITING
				elif in_array "$WORD" "${COMMAND_OPTS[@]}"; then
					CUR_COMMAND="$WORD"
					STATE=$STATE_COMMAND_WAITING
				fi
				;;
			$STATE_CPU_WAITING)
				(( FLAGS |= $FLAG_CPU ))
				STATE=$STATE_BASE
				;;
			$STATE_COMMAND_VALUE_WAITING)
				STATE=$STATE_COMMAND_WAITING
				;;
			$STATE_COMMAND_WAITING)
				CUR_OPT="$WORD"
				case "$CUR_COMMAND" in
					help)
						return 0
						;;
					frequency-info)
						if in_array "$WORD" "${FREQINFOSET_OUTPUT_OPTS[@]}"; then
							(( $FLAGS_FREQINFO & $FLAG_FREQINFOSET_OUTPUT )) && return 1
							(( FLAGS_FREQINFO |= $FLAG_FREQINFOSET_OUTPUT ))
						elif in_array "$WORD" "${FREQINFOSET_HUMAN_OPTS[@]}"; then
							(( $FLAGS_FREQINFO & $FLAG_FREQINFOSET_HUMAN )) && return 1
							(( FLAGS_FREQINFO |= $FLAG_FREQINFOSET_HUMAN ))
						elif in_array "$WORD" "${FREQINFOSET_PROC_OPTS[@]}"; then
							(( $FLAGS_FREQINFO & $FLAG_FREQINFOSET_PROC )) && return 1
							(( $FLAGS_FREQINFO & $FLAG_FREQINFOSET_OUTPUT )) && return 1
							(( FLAGS_FREQINFO |= ( $FLAG_FREQINFOSET_OUTPUT | $FLAG_FREQINFOSET_PROC ) ))
						fi
						;;
					frequency-set)
						# The -f|--freq option is incompatible with ALL the other parameters
						(( $FLAGS_FREQSET & $FLAG_FREQSET_FREQ )) && return 1
						if in_array "$WORD" "${FREQSET_MIN_OPTS[@]}"; then
							(( $FLAGS_FREQSET & $FLAG_FREQSET_MIN )) && return 1
							(( FLAGS_FREQSET |= $FLAG_FREQSET_MIN ))
						elif in_array "$WORD" "${FREQSET_MAX_OPTS[@]}"; then
							(( $FLAGS_FREQSET & $FLAG_FREQSET_MAX )) && return 1
							(( FLAGS_FREQSET |= $FLAG_FREQSET_MAX ))
						elif in_array "$WORD" "${FREQSET_GOV_OPTS[@]}"; then
							(( $FLAGS_FREQSET & $FLAG_FREQSET_GOV )) && return 1
							(( FLAGS_FREQSET |= $FLAG_FREQSET_GOV ))
							STATE=$STATE_COMMAND_VALUE_WAITING
						elif in_array "$WORD" "${FREQSET_RELATED_OPTS[@]}"; then
							(( $FLAGS_FREQSET & $FLAG_FREQSET_RELATED )) && return 1
							(( FLAGS_FREQSET |= $FLAG_FREQSET_RELATED ))
						elif in_array "$WORD" "${FREQSET_FREQ_OPTS[@]}"; then
							(( FLAGS_FREQSET |= $FLAG_FREQSET_FREQ ))
						fi
						;;
					idle-info)
						return 0
						;;
					'set'|'info')
						if in_array "$WORD" "${INFOSET_PERFBIAS_OPTS[@]}"; then
							(( $FLAGS_INFOSET & $FLAG_INFOSET_PERFBIAS )) && return 1
							(( FLAGS_INFOSET |= $FLAG_INFOSET_PERFBIAS ))
						elif in_array "$WORD" "${INFOSET_SCHEDMC_OPTS[@]}"; then
							(( $FLAGS_INFOSET & $FLAG_INFOSET_SCHEDMC )) && return 1
							(( FLAGS_INFOSET |= $FLAG_INFOSET_SCHEDMC ))
							STATE=$STATE_COMMAND_VALUE_WAITING
						elif in_array "$WORD" "${INFOSET_SCHEDSMT_OPTS[@]}"; then
							(( $FLAGS_INFOSET & $FLAG_INFOSET_SCHEDSMT )) && return 1
							(( FLAGS_INFOSET & $FLAG_INFOSET_SCHEDSMT ))
							STATE=$STATE_COMMAND_VALUE_WAITING
						fi
						;;
					monitor)
						(( $FLAGS_MONITOR & $FLAG_MONITOR_LIST )) && return 1
						if in_array "$WORD" "${MONITOR_LIST_OPTS[@]}"; then
							(( FLAGS_MONITOR |= $FLAG_MONITOR_LIST ))
						elif in_array "$WORD" "${MONITOR_INTERVAL_OPTS[@]}"; then
							(( $FLAGS_MONITOR & $FLAG_MONITOR_INTERVAL )) && return 1
							(( FLAGS_MONITOR |= $FLAG_MONITOR_INTERVAL ))
							STATE=$STATE_COMMAND_VALUE_WAITING
						elif in_array "$WORD" "${MONITOR_ONLY_OPTS[@]}"; then
							(( $FLAGS_MONITOR & $FLAG_MONITOR_ONLY )) && return 1
							(( FLAGS_MONITOR |= $FLAG_MONITOR_ONLY ))
							STATE=$STATE_COMMAND_VALUE_WAITING
						elif in_array "$WORD" "${MONITOR_SCHED_OPTS[@]}"; then
							(( $FLAGS_MONITOR & $FLAG_MONITOR_SCHED )) && return 1
							(( FLAGS_MONITOR |= $FLAG_MONITOR_SCHED ))
						elif in_array "$WORD" "${MONITOR_VERBOSE_OPTS[@]}"; then
							(( $FLAGS_MONITOR & $FLAG_MONITOR_VERBOSE )) && return 1
							(( FLAGS_MONITOR |= $FLAG_MONITOR_VERBOSE ))
						fi
						;;
				esac
				;;
		esac
	done

	OPTS=""
	case $STATE in
		$STATE_BASE)
			OPTS="${COMMAND_OPTS[@]} ${HELP_OPTS[@]} ${VERSION_OPTS[@]}"
			(( ~$FLAGS & $FLAG_DEBUG )) && OPTS="$OPTS ${DEBUG_OPTS[@]}"
			(( ~$FLAGS & $FLAG_CPU )) && OPTS="$OPTS ${CPU_OPTS[@]}"
			;;
		$STATE_CPU_WAITING)
			OPTS="${CPUS[@]}"
			;;
		$STATE_COMMAND_VALUE_WAITING)
			case "$CUR_OPT" in
				"${FREQSET_GOV_OPTS[@]}")
					OPTS="${FREQSET_GOV_VALUES[@]}"
				;;
			esac
			;;
		$STATE_COMMAND_WAITING)
			case "$CUR_COMMAND" in
				help)
					OPTS="${COMMAND_OPTS[@]}"
					;;
				frequency-info)
					if (( ~$FLAGS_FREQINFO & $FLAG_FREQINFOSET_OUTPUT )); then
						# The -o|--proc option is incompatible with the -c|--cpu global option
						if (( ~$FLAGS_FREQINFO & $FLAG_FREQINFOSET_PROC )); then
							(( ~$FLAGS & $FLAG_CPU )) && OPTS="$OPTS ${FREQINFOSET_PROC_OPTS[@]}"
						fi
						OPTS="$OPTS ${FREQINFOSET_OUTPUT_OPTS[@]}"
					fi
					(( ~$FLAGS_FREQINFO & $FLAG_FREQINFOSET_HUMAN )) && OPTS="$OPTS ${FREQINFOSET_HUMAN_OPTS[@]}";
					;;
				frequency-set)
					(( $FLAGS_FREQSET & $FLAG_FREQSET_FREQ )) && return 0
					(( ~$FLAGS_FREQSET & $FLAG_FREQSET_MIN )) && OPTS="$OPTS ${FREQSET_MIN_OPTS[@]}"
					(( ~$FLAGS_FREQSET & $FLAG_FREQSET_MAX )) && OPTS="$OPTS ${FREQSET_MAX_OPTS[@]}"
					(( ~$FLAGS_FREQSET & $FLAG_FREQSET_GOV )) && OPTS="$OPTS ${FREQSET_GOV_OPTS[@]}"
					(( ~$FLAGS_FREQSET & $FLAG_FREQSET_RELATED )) && OPTS="$OPTS ${FREQSET_RELATED_OPTS[@]}"
					[ $FLAGS_FREQSET -eq 0 ] && OPTS="$OPTS ${FREQSET_FREQ_OPTS[@]}"
					;;
				idle-info)
					return 0
					;;
				'set'|'info')
					(( ~$FLAGS_INFOSET & $FLAG_INFOSET_PERFBIAS )) && OPTS="$OPTS ${INFOSET_PERFBIAS_OPTS[@]}"
					(( ~$FLAGS_INFOSET & $FLAG_INFOSET_SCHEDMC )) && OPTS="$OPTS ${INFOSET_SCHEDMC_OPTS[@]}"
					(( ~$FLAGS_INFOSET & $FLAG_INFOSET_SCHEDSMT )) && OPTS="$OPTS ${INFOSET_SCHEDSMT_OPTS[@]}"
					;;
				monitor)
					(( $FLAGS_MONITOR & $FLAG_MONITOR_LIST )) && return 0
					if (( ~$FLAGS_MONITOR & $FLAG_MONITOR_INTERVAL )); then
						OPTS="$OPTS ${MONITOR_INVERVAL_OPTS[@]}"
						# The monitor command accepts a command as an argument.
						(( FLAGS |= $FLAG_COMPGEN_COMMAND ))
					fi
					(( ~$FLAGS_MONITOR & $FLAG_MONITOR_ONLY )) && OPTS="$OPTS ${MONITOR_ONLY_OPTS[@]}"
					(( ~$FLAGS_MONITOR & $FLAG_MONITOR_SCHED )) && OPTS="$OPTS ${MONITOR_SCHED_OPTS[@]}"
					(( ~$FLAGS_MONITOR & $FLAG_MONITOR_VERBOSE )) && OPTS="$OPTS ${MONITOR_VERBOSE_OPTS[@]}"
					[ $FLAGS_MONITOR -eq 0 ] && OPTS="$OPTS ${MONITOR_LIST_OPTS[@]}"
					;;
				
			esac
			;;
	esac

	(( $FLAGS & $FLAG_COMPGEN_COMMAND )) && COMPGEN_EXTRA="$COMPGEN_EXTRA -c"
	COMPREPLY=( $(compgen $COMPGEN_EXTRA -W "${OPTS}" -- ${CUR_WORD}) )
	return 0
}


complete -r cpupower 2>/dev/null
complete -F _cpupower cpupower
