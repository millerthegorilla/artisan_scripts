#!/bin/bash
project_name=ceramic_isles
nom=Richard
read -p "name : " names
name=${names:-/opt/${project_name}/}
echo ${name}
