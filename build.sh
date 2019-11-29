#!/bin/sh
skip=44

tab='	'
nl='
'
IFS=" $tab$nl"

umask=`umask`
umask 77

gztmpdir=
trap 'res=$?
  test -n "$gztmpdir" && rm -fr "$gztmpdir"
  (exit $res); exit $res
' 0 1 2 3 5 10 13 15

if type mktemp >/dev/null 2>&1; then
  gztmpdir=`mktemp -dt`
else
  gztmpdir=/tmp/gztmp$$; mkdir $gztmpdir
fi || { (exit 127); exit 127; }

gztmp=$gztmpdir/$0
case $0 in
-* | */*'
') mkdir -p "$gztmp" && rm -r "$gztmp";;
*/*) gztmp=$gztmpdir/`basename "$0"`;;
esac || { (exit 127); exit 127; }

case `echo X | tail -n +1 2>/dev/null` in
X) tail_n=-n;;
*) tail_n=;;
esac
if tail $tail_n +$skip <"$0" | gzip -cd > "$gztmp"; then
  umask $umask
  chmod 700 "$gztmp"
  (sleep 5; rm -fr "$gztmpdir") 2>/dev/null &
  "$gztmp" ${1+"$@"}; res=$?
else
  echo >&2 "Cannot decompress $0"
  (exit 127); res=127
fi; exit $res
??醈build.sh K,(袽O-Q(-HI,I濯,蛥1J2髪Ksr驅蚶R赛虃捘詁]7.鋵|e| 狣7€)耨tr
?
浈枖?e僥?RsrH0痆笂RSt敒餄鴟鳒?z?違イ ?>/17¤蓭礝?胯jz薮3? ?9/?%5>? 蓽针燊/J??劅兜mx谘霾??C缬鮩/'-E不 备構?鋉[呍旚T軩昷樦Z載 侃@$!?@??胎礦*?д*ī)??? j棱\ 顴俊
  
