#!/bin/sh
# original code from https://gist.github.com/riocampos/5656450

LANG=ja_JP.utf8

date=`date '+%Y-%m-%d-%H_%M'`
swfVfy="http://www3.nhk.or.jp/netradio/files/swf/rtmpe.swf"

outdir="."

if [ $# -le 1 ]; then
  echo "usage : $0 channel_name duration(minuites) [outputdir] [prefix]"
  exit 1
fi

if [ $# -ge 2 ]; then
  channel=$1
  DURATION=`expr $2 \* 60 + 60`
fi
if [ $# -ge 3 ]; then
  outdir=$3
fi
PREFIX=${channel}
if [ $# -ge 4 ]; then
  PREFIX=$4
fi

#
# set channel
#
case $channel in
    "NHK1")
    rtmp="rtmpe://netradio-r1-flash.nhk.jp"
    playpath="NetRadio_R1_flash@63346"
    ;;
    "NHK2")
    rtmp="rtmpe://netradio-r2-flash.nhk.jp"
    playpath="NetRadio_R2_flash@63342"
    ;;
    "FM")
    rtmp="rtmpe://netradio-fm-flash.nhk.jp"
    playpath="NetRadio_FM_flash@63343"
    ;;
    "NHK1_SENDAI")
    rtmp="rtmpe://netradio-hkr1-flash.nhk.jp"
    playpath="NetRadio_HKR1_flash@108442"
    ;;
    "FM_SENDAI")
    rtmp="rtmpe://netradio-hkfm-flash.nhk.jp"
    playpath="NetRadio_HKFM_flash@108237"
    ;;
    "NHK1_NAGOYA")
    rtmp="rtmpe://netradio-ckr1-flash.nhk.jp"
    playpath="NetRadio_CKR1_flash@108234"
    ;;
    "FM_NAGOYA")
    rtmp="rtmpe://netradio-ckfm-flash.nhk.jp"
    playpath="NetRadio_CKFM_flash@108235"
    ;;
    "NHK1_OSAKA")
    rtmp="rtmpe://netradio-bkr1-flash.nhk.jp"
    playpath="NetRadio_BKR1_flash@108232"
    ;;
    "FM_OSAKA")
    rtmp="rtmpe://netradio-bkfm-flash.nhk.jp"
    playpath="NetRadio_BKFM_flash@108233"
    ;;
    *)
    echo "failed channel"
    exit 1
    ;;
esac

#
# rtmpdump
#
/usr/bin/rtmpdump \
         --rtmp $rtmp \
         --playpath $playpath \
         --app "live" \
         --swfVfy $swfVfy \
         --live \
         --stop ${DURATION} \
         -o "/mnt/usb_hdd/radio/mp3/${channel}_${date}"

#ffmpeg -loglevel quiet -y -i "/tmp/${channel}_${date}" -acodec copy "${outdir}/${PREFIX}_${date}.m4a"
/usr/bin/ffmpeg -loglevel quiet -y -i "/mnt/usb_hdd/radio/mp3/${channel}_${date}" -acodec libmp3lame -ab 128k "/mnt/usb_hdd/radio/mp3/${PREFIX}_${date}.mp3"

bash /mnt/usb_hdd/radio/dropbox_uploader.sh upload "/mnt/usb_hdd/radio/mp3/${PREFIX}_${date}.mp3" "/NHK/${PREFIX}_${date}.mp3"

if [ $? = 0 ]; then
  rm -f "/mnt/usb_hdd/radio/mp3/${channel}_${date}"
fi
