function super_access()
{
    if [[ -z ${SUNAME} ]]
    then
        read -p "Enter the name of your superuser account : " SUNAME
    fi
    echo -e "enter the password for ${SUNAME}"
    local command="${1} || exit 123;"
    i=0
    until su ${SUNAME} -c "sudo -S ${command}"
    do
        EXITCODE=$?
        i=$(( i + 1 ))
        if [[ ${i} -eq 3 ]]
        then
            echo -e "3 Incorrect password attempts! Sorry you will have to run the script again."
            exit 1
        fi
        if [[ ${EXITCODE} == 123 ]]
        then
            echo -e "Podman has failed in some way.  The script will now exit.  Run ./artisan_run clean to clear up"
            exit 1
        fi
    done
}