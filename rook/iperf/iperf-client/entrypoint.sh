#!/bin/sh
set -eu

iperf -c "$TARGET"
sleep 100000