#!/bin/bash

function CD()
{
    echo $(dirname $(realpath $(pwd)));
}
CURRENT_DIR=$(CD)