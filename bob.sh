function install_check()
{
  INSTALLED="installed."
  while [[ "installed." == "${INSTALLED}" ]]
  do
    for line in $(find . -type d);
    do
      if [[ ${line} != ".git" && ${line:0:26} != "./dockerfiles/django/media" && "0555" -ne $(stat -c '%a' ${line}) ]];
      then
        echo 1 $line
        INSTALLED="not installed!";
	break;
      elif [[ ${line} == ".git" && "0755" -ne $(stat -c '%a' ${line}) ]];
      then
        echo 2
        INSTALLED="not installed!";
	break;
      elif [[ ${line:0:26} == "./dockerfiles/django/media" && "0770" -ne $(stat -c '%a' ${line}) ]];
      then
        echo 3
        INSTALLED="not installed!";
	break;
      fi
    done
    if [[ $INSTALLED == "not installed!" ]];
    then
	break;
    fi
    for line in $(find -type f -name "*.sh")
    do
      if [[ ${line} != "./templates/maria/maria.sh" && "0550" -ne $(stat -c '%a' ${line}) ]];
      then
        echo 4
        INSTALLED="not installed!"
	break;
      elif [[ ${line} == "./templates/maria/maria.sh" && "0444" -ne $(stat -c '%a' ${line}) ]];
      then
        echo 5
        INSTALLED="not installed!"
	break;
      fi
    done
  done
  ## can't be arsed to finish this, should be using ansible instead of my lousy scripts.
  echo -e "Scripts are ${INSTALLED}";
}

set +x
install_check
set -x
