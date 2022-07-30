#!/bin/bash

function CD()
{
    echo $(dirname $(realpath ${BASH_SOURCE[0]}));
}
CURRENT_DIR=$(CD)