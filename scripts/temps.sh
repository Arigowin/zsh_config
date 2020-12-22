#!/bin/bash

while :; do sensors ; echo '' ; sudo hddtemp /dev/sda /dev/sdb ; sleep 1; clear ; done
