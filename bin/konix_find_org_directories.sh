#!/bin/bash

find "$1" -name "*.org"|sed 's-/[^/]\+$-/-'|uniq|egrep -v '/data/'
