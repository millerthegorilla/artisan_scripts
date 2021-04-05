#!/bin/bash
echo -e "remove logs dir or save logs and remove logs dir(choose a number)?"
select yn in "Yes" "No" "Save"; do
    case $yn in
        Yes ) logs_remove=1; break;;
        No ) logs_remove=0; break;;
        Save ) logs_remove=2; break;;
    esac
done

if [[ logs_remove -eq 2 ]]
then
	echo "yeah baby, yeah!"
fi
