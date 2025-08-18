#!/bin/sh
./configuration_managment.sh
source read_source.sh
source synthesis.sh
source link.sh
source post_synth_opt.sh
source place.sh
source phys_opt.sh
source route.sh
source phys_opt.sh
source write_bitstream.sh
