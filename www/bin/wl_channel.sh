#!/bin/ash                                                                                            
# Sabai Technology - Apache v2 licence                                                                
# copyright 2014 Sabai Technology 

UCI_PATH="-c /configs"

# get all channels on Wifi device                                                              
channel_all=$(iw list | grep "\[" | awk '{print $4}' | cut -d "[" -f2 | cut -d "]" -f1 | tail -n 1)

# get only available Wifi device                                                              
channel="$(iw list | grep "\[" | grep "disabled" | awk '{print $4}' | cut -d "[" -f2 | cut -d "]" -f1 | head -1)"
channel_aval="$(( channel-1 ))"

# set number of Wifi channels to sabai config
uci $UCI_PATH set sabai.wlradio0.channels.qty="$channel_aval"
uci $UCI_PATH commit sabai

# set current channel
channel_curr=$(iw dev wlan0 info | grep "channel" | awk '{print $2}')
uci $UCI_PATH set sabai.wlradio0.channel_freq="$channel_curr"
uci $UCI_PATH set sabai.wlradio1.channel_freq="$channel_curr"
uci $UCI_PATH commit sabai
