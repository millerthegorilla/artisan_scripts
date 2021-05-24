function super_access()
{
    local command="${1} || exit 123;"
    i=0
    until su ${SUNAME} -c "sudo -S ${command}"
    do
        EXITCODE=$?
        i=$(( i + 1 ))
        if [[ ${i} -eq 3 || EXITCODE -eq 123 ]]
        then
            echo -e "3 Incorrect password attempts! Sorry you will have to run the script again."
            exit 1
        fi
    done
}