#!/bin/bash

date=`date +%s`

tar -cvvjpf overlay.$date.tar.bz2 out/5054part out/5867part out/ba4 out/damage out/ebersp out/so42 out/solex out/tools out/wog69 out/wog72

exit 0
