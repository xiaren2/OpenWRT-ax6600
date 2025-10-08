#!/bin/sh


uci set network.globals.ula_prefix='auto'
uci commit network

exit 0


