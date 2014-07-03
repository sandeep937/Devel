#!/bin/bash

log ( ) {
    echo "## $*"
}

die ( ) {
    log "$*"
    exit 1
}

gaps_launch_freeze_pre_hook ( ) {
    local hook="${1}"
    local message="${2}"
    if [ -f "${hook}" ]
    then
        log "Launching the freeze prehook (${hook}) for $message"
        bash -x "${hook}" \
            || die "Failed to launch the freeze prehook for ${message}"
    fi
}
GITANNEXFREEZE_PRE_HOOK=".gitannexfreeze_prehook"

pushd `git -c core.bare=false rev-parse --show-toplevel`
log "First merge the annex in case someone else pushed the sync branch here"
git annex merge || die "Could not merge"
gaps_launch_freeze_pre_hook "${GITANNEXFREEZE_PRE_HOOK}" "$(pwd)"
gaps_launch_freeze_pre_hook "${GITANNEXFREEZE_PRE_HOOK}_${HOSTNAME}" "$(pwd)"
if [ "$(git config annex.direct)" == "true" ]
then
    log "In direct mode, I have to make git sync before git annex"
    git -c core.bare=false diff --name-only --diff-filter=M -z | xargs --no-run-if-empty -0 git -c core.bare=false add -v
    log "Remove from the index files that were deleted in the working tree"
    git -c core.bare=false diff --name-only --diff-filter=D -z | xargs --no-run-if-empty -0 git -c core.bare=false rm --cached || die "Could not remove deleted files"
fi
log "Annex add new files"
git annex add || die "Could not annex add"
if ! [ "$(git config annex.direct)" == "true" ]
then
	log "In indirect mode, syncing the working copy to index after git annex"
	git add -A :/ || die "Could not add -A files"
else
    log "Add files ignored by git annex"
    git -c core.bare=false ls-files --others --exclude-standard|xargs -0 --no-run-if-empty git add -v
fi
# taken from https://github.com/svend/home-bin/blob/master/git-autocommit
hostname=`hostname`
dnsdomainname=`dnsdomainname 2>/dev/null || true`
if [ -n "$dnsdomainname" ]; then
    hostname="$hostname.$dnsdomainname"
fi

if [ -z "$GIT_COMMITTER_EMAIL" ]; then
    export GIT_COMMITTER_EMAIL=`whoami`"@$hostname"
fi
# all except the type change in direct mode
if [ -n "$(git diff --cached --name-only --diff-filter=ACDMRUXB)" ]
then
    echo "Perform the commit"
    git commit -m "Freezing of repo by $LOGNAME at $HOSTNAME" || die "Could not commit"
else
    echo "No need to commit"
fi
popd
