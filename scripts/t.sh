grep 'block_ad' "NoAdsService.sh" | grep -o '".*"' | tr -d '"' | while IFS= read -r p
do
    echo $p
    #[ -n "$p" ]&&[ -e "$p" ]&&find "$p" \( -type f -o -type d \) |while IFS= read -r f;do if [ -d "$f" ];then lsattr -d "$f"|grep -q "i-"&&{ chattr -i "$f";rmdir "$f";};else lsattr "$f"|grep -q "i-"&&{ chattr -i "$f";rm -f "$f";};fi;done;
done