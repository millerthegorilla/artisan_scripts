function super_access()
{
    ERR_MSG="The script will now exit.  Run ./artisan_run clean to clear up"
    if [[ -z ${SUNAME} ]]
    then
        read -p "Enter the name of your superuser account : " SUNAME
    fi
    if [[ $(id ${SUNAME} > /dev/null 2>&1; echo $?) == 1 ]]
    then
        echo -e "Error! That username doesn't exist!"
        exit 1
    else
        echo -e "Enter the password for ${SUNAME}"
        local command="${1} || exit 123;"
        i=0
        if [[ -n ${command} ]]
        then
            echo -e "Attempting to obtain permission for ${command}"
        fi
        until su ${SUNAME} -c "sudo -S ${command}"
        do
            EXITCODE=$?
            i=$(( i + 1 ))
            if [[ ${i} -eq 3 ]]
            then
                echo -e "3 Incorrect password attempts! ${ERR_MSG}"
                exit 1
            fi
            if [[ ${EXITCODE} == 123 ]]
            then
                echo -e "Podman has failed in some way. ${ERR_MSG}"
                exit 1
            fi
        done
    fi
}