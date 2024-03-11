#!/bin/bash

goaccess ../04/logs/*.log --config-file=goaccess.conf
goaccess ../04/logs/*.log -p goaccess.conf -o report.html
