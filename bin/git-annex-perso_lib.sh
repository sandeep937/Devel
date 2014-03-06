#!/bin/bash

source "${KONIX_LIB_DIR}/lib_bash.sh"

GITANNEX_BIG_FILE=".gitannexbig"
GITANNEXSYNC_PRE_HOOK=".gitannexsync_prehook"
GITANNEXFREEZE_PRE_HOOK=".gitannexfreeze_prehook"
GITANNEXSYNC_POST_HOOK=".gitannexsync_posthook"
GITANNEXSYNC_REMOTES=".gitannexremotes"
GITANNEXSYNC_CONFIG=".gitannexconfig"
GITANNEXSYNC_CONTEXTS=".gitannexcontexts"
GITANNEXSYNC_INIT="git-annex-perso_init.sh"

gaps_log ( ) {
    echo "## $*"
}

gaps_log_info ( ) {
    echo -n "${COLOR_FG_GREEN}"
    gaps_log "$*${COLOR_RESET}"
}

gaps_show_date_maybe ( ) {
    [ -n "${KONIX_GIT_ANNEX_PERSO_SHOW_DATES}" ] && date
}

gaps_compute_remotes_internal ( ) {
    local remotes="$(/bin/ls -1 ${GITANNEXSYNC_REMOTES})"
    all_remotes=""
    local git_remotes="$(git remote)"
    for remote in ${git_remotes}
    do
        if echo ${remotes}|grep -v -q ${remote}
        then
            if git config remote.${remote}.url > /dev/null
            then
                gaps_error "The git remote ${remote} is not known by git-annex-perso-sync"
            else
                gaps_log_info "${remote} has no url. It must be a special remote"
            fi
        fi
    done
    # Append to all_remotes only not dead remotes
    for remote in ${remotes}
    do
        local remote_path="${GITANNEXSYNC_REMOTES}/${remote}"
        gaps_extract_context_independent_remote_info "${remote_path}"
        if [ -f "${dead}" ]
        then
            gaps_warn "Remote ${remote} considered dead then ignored"
        else
            all_remotes="${all_remotes}
${remote}"
        fi
    done
}

gaps_compute_remotes ( ) {
    local filter="$1"
    gaps_compute_remotes_internal
    if [ -n "${filter}" ]
    then
        gaps_log "Filter remotes with ${filter}"
	    remotes="$(echo "${all_remotes}"|grep "${filter}")"
    else
        remotes="${all_remotes}"
    fi
    gaps_log "Operations will be limited by remotes:
${remotes}"
}

gaps_error ( ) {
    gaps_log "${COLOR_FG_RED}ERROR: $*${COLOR_RESET}" >&2
}

gaps_error_n_quit ( ) {
    gaps_error "$*"
	exit 1
}

gaps_warn ( ) {
    gaps_log "${COLOR_FG_YELLOW}WARNING: $*${COLOR_RESET}" >&2
}

gaps_error_and_continue ( ) {
    gaps_error "$@"
    continue
}

gaps_error_and_quit ( ) {
    gaps_error "$@"
    exit 2
}

gaps_warn_and_continue ( ) {
    gaps_warn "$@"
    continue
}

gaps_assert ( ) {
    local condition="$1"
    local message="$2"
    eval "${condition}" || {
        gaps_error "${message}"
        gaps_error "exit now"
        exit 2
    }
}

gaps_ask_for_confirmation ( ) {
    local message="${*}"
    echo "${message}"
    echo -n "(y/n): "
	read res
	if [ "$res" == "y" ]
	then
        return 0
	else
        return 1
    fi
}

gaps_source_script_maybe ( ) {
	local script="$1"
	if [ -e "${script}" ]
	then
		gaps_log "Launching ${script}"
		cat "${script}"
		. "${script}"
	fi
}

gaps_launch_script ( ) {
    bash -x "$@"
}

gaps_launch_config ( ) {
    if [ -f "${GITANNEXSYNC_CONFIG}" ]
    then
        gaps_log "Launching the config script"
        gaps_launch_script "${GITANNEXSYNC_CONFIG}"
        gaps_assert "[ $? -eq 0 ]" "Failed to launch the config script ${GITANNEXSYNC_CONFIG}"
    fi

}

gaps_launch_availhook ( ) {
    local availhook="${1}"
    local url="${2}"
    local message="${3}"
    gaps_log "Launching the availhook for $message"
    if [ -f "${availhook}" ]
    then
        gaps_launch_script "${availhook}" "${url}" \
            || return 1
    fi
	return 0
}

gaps_launch_availhook_or_continue ( ) {
    local availhook="${1}"
    local url="${2}"
    local message="${3}"
	gaps_launch_availhook "$@" \
		|| gaps_error_and_continue "Failed to launch the availhook for ${message}"
}

gaps_launch_prehook ( ) {
    local prehook="${1}"
    local url="${2}"
    local message="${3}"
    gaps_log "Launching the prehook for $message"
    if [ -f "${prehook}" ]
    then
        gaps_launch_script "${prehook}" "${url}" \
            || gaps_error_and_continue "Failed to launch the prehook for ${message}"
    fi
}

gaps_launch_freeze_pre_hook ( ) {
    local hook="${1}"
    local message="${2}"
    gaps_log "Launching the freeze prehook for $message"
    if [ -f "${hook}" ]
    then
        gaps_launch_script "${hook}" \
            || gaps_error_and_quit "Failed to launch the freeze prehook for ${message}"
    fi
}

gaps_launch_posthook ( ) {
    local posthook="${1}"
    local url="${2}"
    local message="${3}"
    if [ -f "${posthook}" ]
    then
        gaps_launch_script "${posthook}" "${url}" \
            || gaps_error "Failed to launch the posthook for ${message}"
    fi
}

gaps_posthook_launch_maybe ( ) {
    if [ -f "${posthook}" ]
    then
        gaps_log "Launching the posthook"
        bash -x "${posthook}" "$url"
        if [ $? -ne 0 ]
        then
            gaps_log "Failed to launch the posthook"
        fi
    fi
}

gaps_remote_initialized_p ( ) {
    local remote_name="${1}"
    git remote | grep -q "^$remote_name$"
}

gaps_remote_here_p ( ) {
    local remote_name="${1}"
    [ "${HOSTNAME}" == "${remote_name}" ]
}

gaps_remote_initialized_or_here_p ( ) {
    local remote_name="${1}"
    gaps_remote_here_p "${remote_name}" \
        || gaps_remote_initialized_p "${remote_name}"
}

gaps_extract_remote_info_from_dir ( ) {
    local remote_path="$1"
    url="$(cat ${remote_path}/url)"
    url="$(eval echo $(echo $url))"
    availhook="${remote_path}/availhook"
    prehook="${remote_path}/prehook"
    posthook="${remote_path}/posthook"
    sync_posthook="${remote_path}/sync_posthook"
}

gaps_extract_context_independent_remote_info ( ) {
    local remote_path="${1}"
    group_file="${remote_path}/group"
	group="$(if [ -e ${group_file} ]; then cat ${group_file} ; fi)"
    wanted_file="${remote_path}/wanted"
	wanted="$(if [ -e ${wanted_file} ] ; then cat ${wanted_file} ; fi)"
	dead="${remote_path}/dead"
}

gaps_remotes_fix ( ) {
    local REMOTES="${1}"
    gaps_log_info "Checking inconsistency in remotes"
    if [ -d "${GITANNEXSYNC_REMOTES}" ]
    then
        gaps_compute_contexts
        gaps_compute_remotes "${REMOTES}"
        for remote in ${remotes}
        do
	        gaps_log_info "Checking remote $remote"
            if ! gaps_extract_remote_info "${contexts}" "${remote}"
            then
                gaps_warn "Could not find info for remote ${remote} in contexts ${contexts}"
                continue
            fi
            if ! gaps_remote_initialized_or_here_p "${remote}"
            then
                gaps_warn "Remote $remote_name not initialized"
				gaps_log "Is it available ?"
				gaps_launch_availhook_or_continue "${availhook}" "${url}" "${remote_name}"
				gaps_log "It is available! Now, trying to initialize it"
                if ! git-annex-perso_initremotes.sh "\b${remote}\b"
                then
                    gaps_warn "Could not initialize remote ${remote}"
                    if gaps_ask_for_confirmation "Consider it dead?"
                    then
                        local remote_path="${GITANNEXSYNC_REMOTES}/${remote}"
                        gaps_extract_context_independent_remote_info "${remote_path}"
                        echo 1 > "${dead}"
                    fi
                    continue
                fi
            fi

            # sanity check that the url is the same in the config only if the
            # remote is not here
            if ! gaps_remote_here_p "${remote}"
            then
                recorded_url="$(git config remote.${remote}.url)"
                if [ "${recorded_url}" != "${url}" ]
                then
                    gaps_warn "URL mismatch"
                    gaps_log "git config: ${recorded_url}"
                    gaps_log "gitannexremotes: ${url}"
                    if gaps_ask_for_confirmation "Record ${url} in git?"
                    then
                        git config remote.${remote}.url ${url}
                    else
					    if ! gaps_ask_for_confirmation "Continue using ${recorded_url}?"
                        then
						    if gaps_ask_for_confirmation "Remove remote ${remote}?"
						    then
							    git remote remove "${remote}"
						    fi
                            gaps_log "Aboooort"
                            continue
                        fi
                    fi
                fi
            fi

            remote_or_here="${remote}"
            if gaps_remote_here_p "${remote}"
            then
                remote_or_here=here
            fi

            # sanity check that the wanted is the same in the config
            recorded_wanted="$(git annex wanted "${remote_or_here}")"
            if [ "${recorded_wanted}" != "${wanted}" ]
            then
                gaps_warn "Wanted mismatch"
                gaps_log "git-annex value: ${recorded_wanted}"
                gaps_log ".gitannexremote: ${wanted}"
                if gaps_ask_for_confirmation "Record ${wanted} in git-annex?"
                then
                    git annex wanted "${remote_or_here}" "${wanted}"
                elif gaps_ask_for_confirmation "Replace .gitannexremote value (${wanted}) by git-annex one (${recorded_wanted})"
                then
                    echo "${recorded_wanted}" > "${wanted_file}"
                fi

            fi
            # sanity check that the group is the same in the config
            recorded_group="$(git-annex-whatgroup.sh "${remote_or_here}")"
            res="$?"
            if [ "$res" == "0" ] && [ "${recorded_group}" != "${group}" ]
            then
                gaps_warn "group mismatch"
                gaps_log "git-annex value: ${recorded_group}"
                gaps_log ".gitannexremote: ${group}"
                if gaps_ask_for_confirmation "Record ${group} in git-annex?"
                then
                    git annex group "${remote_or_here}" "${group}"
                elif gaps_ask_for_confirmation "Replace .gitannexremote value (${group}) by git-annex one (${recorded_group})"
                then
                    echo "${recorded_group}" > "${group_file}"
                fi

            fi
        done
    fi
}

gaps_setup_context_independent_remote_info ( ) {
    if [ -n "$wanted" ]
    then
        gaps_log "$remote_name wants $wanted"
        git annex wanted "$remote_name" $wanted
    fi
    if [ -n "$group" ]
    then
        gaps_log "$remote_name is in group $group"
        git annex group "$remote_name" $group
    fi
}

gaps_extract_remote_info ( ) {
    local contexts="$1"
    local res=1
    remote_name="$2"
    remote_path="${GITANNEXSYNC_REMOTES}/${remote_name}"
    gaps_log "Extracting info from ${remote_path}"
    if [ -f "${remote_path}/url" ]
    then
        gaps_warn "No context information detected in $remote_path"
        gaps_extract_remote_info_from_dir "${remote_path}"
        res=0
    else
        konix_assert_var contexts
        gaps_log "Look for a context information in ${remote_path} suitable with '${contexts}'"
        for context in ${contexts}
        do
            local context_dir="${remote_path}/${context}"
            if [ -d "${context_dir}" ]
            then
                gaps_log "Found context information ${context}"
                gaps_extract_remote_info_from_dir "${context_dir}"
                res=0
                break
            fi
        done
    fi
    gaps_extract_context_independent_remote_info "${remote_path}"
    return ${res}
}

gaps_extract_remote_info_or_continue ( ) {
    local contexts="$1"
    local _remote_name="$2"
    gaps_extract_remote_info "$@" \
        || gaps_error_and_continue "Could not extract info for remote $_remote_name in any context of $contexts"
}

gaps_compute_contexts ( ) {
    local contexts_program="$(which konix_contexts.sh)"
    contexts=""
    if [ -n "${contexts_program}" ]
    then
        contexts="$(${contexts_program}) ${contexts}"
    fi

    if [ -f "${GITANNEXSYNC_CONTEXTS}" ]
    then
        contexts="$(bash "${GITANNEXSYNC_CONTEXTS}") ${contexts}"
    fi

    gaps_log "I am in contexts ${contexts}"
}

gaps_group () {
    local remote_name="$1"
    local uuid="$(git config remote.${remote_name}.annex-uuid)" \
        | gaps_error_and_quit "Could not get the annex uuid of remote ${remote_name}"
    git show git-annex:group.log|grep "^${uuid}"|cut -d $' ' -f 2
}