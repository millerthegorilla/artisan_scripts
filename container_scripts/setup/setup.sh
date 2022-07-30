#!/bin/bash

function CD()
{
    echo $(dirname $(realpath ${BASH_SOURCE});
}
CURRENT_DIR=$(CD)