# Set this file to be automatically sourced in /etc/profile.d (or elsewhere as needed)
# and configure the following paths to force a message on users when they navigate into
# a certain area of a filesystem.
# 
# This was originally written to notify users of a filesystem being decommissioned, but may also be
# useful to issue warnings about purgable areas, etc.

# Navigating to this path, or any subdirectory of it, will trigger the message.
export DIRMESSAGE_PATH=/threshold/path

# Point this to the location of the message file.
# The message file is a simple plain-text format.
export DIRMESSAGE_MESSAGEFILE=/path/to/message/file

# Configure the number of times the message is shown per shell.
export DIRMESSAGE_NOTICES_REMAINING=2

# By sourcing this bash function (instead of aliasing `cd` to something else) we safely preserve any
# existing aliases of `cd` that an end-user may already have, while still wrapping it to add functionality.
function cd {
    # Use `builtin` to maintain all of the normal `cd` functionality.
    builtin cd "$@" || return
    
    # Check if the true path to any destination is equal to or a superstring of $DIRMESSAGE_PATH.
    # -- Since navigating directories using symbolic links will report the link path in $PWD, a simple
    # -- check on $PWD is not sufficient here. It's possible to be in one area of the filesystem when $PWD
    # -- would indicate otherwise. To dereference the links, we'll rely on `readlink` being available.
    case $(readlink -m $PWD)/ in
        $DIRMESSAGE_PATH*/*)
            if [[ $DIRMESSAGE_NOTICES_REMAINING -gt 0 && -f $DIRMESSAGE_MESSAGEFILE ]]; then
                cat $DIRMESSAGE_MESSAGEFILE 1>&2;
                export DIRMESSAGE_NOTICES_REMAINING=$(($DIRMESSAGE_NOTICES_REMAINING-1))
            fi
            ;;
    esac
}
