#!/bin/bash
############################################
## EALEKRY
## Compare list with result passing
## Creates statistics about RT
## usage: ./TC_statistics.sh list.txt(create from titan.cfg) logs_path
## output: stats.txt in current dir
###############################################

NEGATIVE=0 ## show only negative statuses
LIST_LOGS=0 ## omit LOGS section

if [ $# -lt 1 ];
then
echo "USAGE: ./TC_statistics.sh logs_path TC_list_file"
echo "OR: ./TC_statistics.shh logs_path (TC list will be taken from titan.cfg)"
echo "OUTPUT: stat.txt in current dir"
exit 1
fi 

TC_LIST=$2
#echo $TC_LIST
if [ $# -eq 1 ];
then
  cat ~/config/titan.cfg | sed -n "/EXECUTE/,// p" | tail -n +2 > /tmp/list
  TC_LIST=/tmp/list
fi


LISTA=$(cat $TC_LIST|sed "s/[^.]*\.//")

FAIL=0
PASS=0
ERROR=0
PASSwRERUN=0
INCONCR=0



for list in $LISTA
do
    ls $1| grep $list | grep pass >> /tmp/checkThose.log
        ls $1| grep $list | grep fail >> /tmp/checkThose.log
        ls $1| grep $list | grep error >> /tmp/checkThose.log
        echo -e '\n' >> /tmp/checkThose.log
done    

#FT info

#Statistics and report

echo -e "===========================PASS_ON_RERUN============================">>stats.txt
for list in $LISTA
do
        pass=$(cat /tmp/checkThose.log| grep $list | grep pass | wc -l)
        fail=$(cat /tmp/checkThose.log| grep $list | grep fail | wc -l)
        error=$(cat /tmp/checkThose.log| grep $list | grep error | wc -l)
               
        if [ $pass -gt 0 ] && ( [ $fail -gt 0 ] || [ $error -gt 0 ]); then
         #echo -e "$list">> stats.txt
         cat $TC_LIST|grep "$list\$">>stats.txt
		 if [ $LIST_LOGS -ne 0 ];
          then
          ls $1| grep $list >> stats.txt
         fi
         let PASSwRERUN+=1
        fi
done

echo -e "===========================FAIL/ERROR============================">>stats.txt
for list in $LISTA
do
        pass=$(cat /tmp/checkThose.log| grep $list | grep pass | wc -l)
        fail=$(cat /tmp/checkThose.log| grep $list | grep fail | wc -l)
        error=$(cat /tmp/checkThose.log| grep $list | grep error | wc -l)
               
        if [ $pass -eq 0 ] && [ $fail -gt 0 ] && [ $error -gt 0 ]; then
 #         echo -e "$list">>stats.txt
		  cat $TC_LIST|grep $list>>stats.txt
          if [ $LIST_LOGS -ne 0 ];
          then
            ls $1| grep $list >> stats.txt
          fi
          let INCONCR+=1
        fi
done



echo -e "===========================FAIL============================">>stats.txt
for list in $LISTA
do
        pass=$(cat /tmp/checkThose.log| grep $list | grep pass | wc -l)
        fail=$(cat /tmp/checkThose.log| grep $list | grep fail | wc -l)
        error=$(cat /tmp/checkThose.log| grep $list | grep error | wc -l)
               
        if [ $pass -eq 0 ] && [ $fail -gt 0 ] && [ $error -eq 0 ]; then
          #echo -e "$list">>stats.txt
		  cat $TC_LIST|grep $list>>stats.txt
          if [ $LIST_LOGS -ne 0 ];
          then
            ls $1| grep $list >> stats.txt
          fi
          let FAIL+=1
        fi
done  

if [ $NEGATIVE -eq 0 ];
then  
  echo -e "===========================PASS============================">>stats.txt
  for list in $LISTA
  do
        pass=$(cat /tmp/checkThose.log| grep $list | grep pass | wc -l)
        fail=$(cat /tmp/checkThose.log| grep $list | grep fail | wc -l)
        error=$(cat /tmp/checkThose.log| grep $list | grep error | wc -l)
               
        if [ $pass -gt 0 ] && [ $fail -eq 0 ] && [ $error -eq 0 ]; then
          #echo -e "$list" >> stats.txt
          cat $TC_LIST|grep $list>>stats.txt
		  if [ $LIST_LOGS -ne 0 ];
          then
          ls $1| grep $list >> stats.txt
          fi
          let PASS+=1
        fi
        
  done
fi


echo -e "===========================ERROR============================">>stats.txt
for list in $LISTA
do
        pass=$(cat /tmp/checkThose.log| grep $list | grep pass | wc -l)
        fail=$(cat /tmp/checkThose.log| grep $list | grep fail | wc -l)
        error=$(cat /tmp/checkThose.log| grep $list | grep error | wc -l)
               
        if [ $pass -eq 0 ] && [ $fail -eq 0 ] && [ $error -gt 0 ]; then
#          echo -e "$list">>stats.txt
		  cat $TC_LIST|grep $list>>stats.txt
          if [ $LIST_LOGS -ne 0 ];
          then
          ls $1| grep $list >> stats.txt
          fi
          let ERROR+=1
        fi
done    


if [ $LIST_LOGS -ne 0 ];
then
  echo -e "==========================================LOGS==========================================\n">>stats.txt
  ls $1|grep tgz>> stats.txt
fi
TOTAL=`cat $TC_LIST |wc -l`
#echo -e "======================================== STATISTICS======================================\n">>stats.txt
#echo -e "TOTAL: $TOTAL">> stats.txt
#echo -e "FAIL: $FAIL">> stats.txt
#echo -e "ERROR: $ERROR">> stats.txt
#echo -e "INCONCR: $INCONCR">> stats.txt
#if [ $NEGATIVE -eq 0 ];
#then
#echo -e "PASS: $PASS">> stats.txt
#fi
#echo -e "PASS with Rerun: $PASSwRERUN">> stats.txt
#echo -e "=========================================== END==========================================\n">> stats.txt
echo -e "======================================== Summary======================================\n"
echo -e "TOTAL: $TOTAL"
echo -e "FAIL: $FAIL"
echo -e "ERROR: $ERROR"
echo -e "INCONCR: $INCONCR"
if [ $NEGATIVE -eq 0 ];
then
  echo -e "PASS: $PASS"
fi
echo -e "PASS with Rerun: $PASSwRERUN"
rm -f /tmp/checkThose.log
rm -f /tmp/list
