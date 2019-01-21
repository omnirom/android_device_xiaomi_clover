#! /vendor/bin/sh

# Copyright (c) 2013, The Linux Foundation. All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#     * Redistributions of source code must retain the above copyright
#       notice, this list of conditions and the following disclaimer.
#     * Redistributions in binary form must reproduce the above copyright
#       notice, this list of conditions and the following disclaimer in the
#       documentation and/or other materials provided with the distribution.
#     * Neither the name of Linux Foundation nor
#       the names of its contributors may be used to endorse or promote
#       products derived from this software without specific prior written
#       permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NON-INFRINGEMENT ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR
# CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
# EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
# PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
# OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
# WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
# OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
# ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#

OMNIADDRESS=/persist/wlan_mac.omni
WLAN_MAC_BIN=/persist/wlan_mac.bin
MACADDRESSBAK=/persist/wlan_mac.backup
MACADDRESSBIN=/persist/wlan_bt/wlan.mac
INTFSTR0="Intf0MacAddress="
INTFSTR1="Intf1MacAddress="
INTFSTR2="Intf2MacAddress="
INTFSTR3="Intf3MacAddress="
MAC0=000AF58989FF
MAC1=000AF58989FE
MAC2=000AF58989FD
MAC3=000AF58989FD

get_mac () {
  if [ -f $MACADDRESSBIN ]; then
    realMac=$(printf "%b"  | od -An -t x1 -w6 -N6  $MACADDRESSBIN | tr -d '\n ')
  else
    if [ -f $WLAN_MAC_BIN ]; then
        checkMac=$(printf "%b"  | od -An -t x1 -w6 -N6  $MACADDRESS | tr -d '\n ')
        if [ $checkMac != $MAC0 ] && [ "${checkMac:0:2}" != "49" ]; then
          realMac=$checkMac
        fi
    else
        realMac=$MAC0
    fi
  fi
}

wlan_mac () {
    wlanMac=$(head -n 1 $MACADDRESS)
    wlanMac=$(echo -e "${wlanMac//$INTFSTR0}")
}

write_mac () {
        cp $WLAN_MAC_BIN $MACADDRESSBAK
        rm -f $OMNIADDRESS
        echo -e  "$INTFSTR0""$realMac" >$OMNIADDRESS
        echo -e  "$INTFSTR1""$MAC1" >>$OMNIADDRESS
        echo -e  "$INTFSTR2""$MAC2" >>$OMNIADDRESS
        echo -e  "$INTFSTR3""$MAC3" "\nEND">>$OMNIADDRESS
        chown wifi $OMNIADDRESS
        chgrp wifi $OMNIADDRESS
}

if [ -f $MACADDRESSBAK ]; then
    get_mac
    wlan_mac
    if [ "${realMac:0:6}" == "${wlanMac:0:6}" ] && [ "${wlanMac:0:2}" != "49" ]; then
        exit 1
    else
        get_mac
        write_mac
    fi
else
    get_mac
    write_mac
fi