#! /bin/bash 
#
#----------------------------------------------------
# Script logic
# 1) given a file FILETOPARSE
# 2) create directory as filename 
# 3) identify subtest SUBTEST: XXX
# 4) identify running threads 
# 5) for all data between Threads started! and Latency histogram (values are in milliseconds) send the data to file FILETOPARSE_subtest_threads_data.csv 
# 6) for all data between Latency histogram (values are in milliseconds) and Empty line send the data to FILETOPARSE_subtest_histogram_threads.txt
# 7) FIND TEST SUMMARY: line if CURRENT threads = 0, then:
#     - FILETOPARSE_subtest_summary_threads.csv 
#     - print next 2 lines else skip one line and print second
# 8) FIND BLOCK: [END] 
#     - set subtest to none
#     - reset threads
#     - reset workingfile to ""
# execution example: bash read_from_file.sh testXYZ_run_all_select_innodb_2023-11-24_13_59.txt /opt/results/
#----------------------------------------------------


ask_confirmation(){
  echo "============================================="
  echo "FILE To Parse ${FILETOPARSE}"
  echo "Number of lines ${NUMBEROFLINES}"
  echo "Local Path  ${LOCPATH}"
  echo "Resulting filename HEAD ${FILEOUTNAME}"
  echo "Output dir/file ${ORIGFILEOUTNAME}"
  echo "============================================="

  if [ "$NOASK" == "false" ]; then
	  read -p "Should continue? [y/n] " -n 1 -r
	else
	  REPLY="y"
  fi 	  
  echo    # (optional) move to a new line
  if [[ $REPLY =~ ^[Yy]$ ]]
  then
      echo "OK .. ";
    else
      echo "Stop processing."
      exit 0;
  fi
}
function check_number(){
#echo "DEBUG check number $1"
if [[ $1 =~ ^[0-9]+$ ]]; then
    is_number="yes"
  else
  	is_number="no"
fi
}

function ProgressBar {
# Process data
# ProgressBar ${COUNTER} ${NUMBEROFLINES}
    let _progress=(${1}*100/${2}*100)/100
    let _done=(${_progress}*4)/10
    let _left=40-$_done
# Build progressbar string lengths
    _fill=$(printf "%${_done}s")
    _empty=$(printf "%${_left}s")

# 1.2 Build progressbar strings and print the ProgressBar line
# 1.2.1 Output example:                           
# 1.2.1.1 Progress : [########################################] 100%
printf "\rProgress : [${_fill// /#}${_empty// /-}] ${_progress}%%"

}


exract_file(){
	
	local type_of_output=""
	i=0
    WRITE=0 
	OLDDATE="NEW"
	COUNTER=0
	SUMMARYLINE1=false
	META=""
	spin=0
    sp="/-\|"




	while read -r LINE
	do
    if [[ $LINE =~ "SUBTEST" ]]; then
	    SUBTEST=$(echo $LINE|sed -e 's/ //gi'|awk -F':' '{print $2}')
	    SUMMARYLINE1=true
	fi

    if [[ $LINE =~ "THREADS" ]] && [ ! "$SUBTEST" == "none" ]; then
	    THREADS=$(echo $LINE|sed -e 's/ //gi'|awk -F'=' '{print $2}')
	fi
  
    if [[ $LINE =~ "META" ]]; then
      META=$LINE
    fi
    
    if [[ $LINE =~ "Threads started" ]] && [ $THREADS > 0 ]; then
       type_of_output="data"
       WRITE=1 
       workingfile="${ORIGFILEOUTNAME}_${SUBTEST}_${THREADS}_${type_of_output}.csv"
       #we go ahead one empty line to go for next series of data
       read -r LINE2
       read -r LINE3
       LINE=${LINE3} 
    fi    


   if [[ $LINE =~ "Latency" ]]; then
       type_of_output="histogram"
       WRITE=1 
       workingfile=${ORIGFILEOUTNAME}_${type_of_output}.txt
       echo "------- ${SUBTEST} -------"  >> ${workingfile}
   fi

   if [[ $LINE =~ "TEST SUMMARY" ]]; then
       type_of_output="summary"
       WRITE=0 
       workingfile=${ORIGFILEOUTNAME}_${type_of_output}.csv
       read -r LINE2 
       if [ $SUMMARYLINE1 == true ];then
           echo "" >> ${workingfile}
           
           if [ "$WITHMETA" == "true" ]; then
	           echo ${META} >> ${workingfile}
	           META=""
           fi
           echo "subtest,${LINE2}" >> ${workingfile}
           SUMMARYLINE1=false
       fi
       read -r LINE3
       echo "${SUBTEST},${LINE3}" >> ${workingfile}
   fi
#   echo "DEBUG: ${type_of_output}"
   if [[ $LINE =~ "BLOCK: [END]" ]]; then
    	WRITE=0
    	SUBTEST="none"
    	THREADS=0
    	workingfile=""	
    fi
   
	if [ $WRITE == 1 ]; then
	    #echo "WRITE IS ON"
		if [ "${type_of_output}" == "data" ]; then
	  	    to_check=$(echo $LINE|awk -F',' '{print $1}')
            #we check if the line has numbers of any text because error in the last case we stop writing 
            check_number $to_check
	  	    if [ "$is_number" == "yes" ]; then
		  		echo $LINE >> ${workingfile}
		  	else
		  		WRITE=0
		  		type_of_output=""
		  	fi
		else
		    to_write=$(echo "$LINE"| sed -e 's/[* ]//g') 
		  	echo $to_write >> ${workingfile}
	  	fi
	fi
	
	((i=i+1))
	
#    printf "\b${sp:spin++%${#sp}:1}"
	
	
	if [ $i -gt 200 ]
	then
	      ProgressBar ${COUNTER} ${NUMBEROFLINES}
 #        printf "At ${COUNTER} Line        "
 	     ((COUNTER=COUNTER+i))
	     i=0
	 fi
	done < ${LOCPATH}/${FILETOPARSE}
	echo ""
}

print_help(){
cat << EOF
$0 <FILE_name> <PATH> <DESTINATION PATH> 
IE:  export PARSEPATH="/opt/results/sysbench/"; for file in `ls ${PARSEPATH}|grep -e 'small'|grep -v '_2_'`;do  ./read_and_get_from_file.sh $file $PARSEPATH /opt/results/processed --noask;done
Optionally you can add as 4th params --noask. The program will not ask for confirmation each time.


EOF
exit 0
}


FILETOPARSE=$1
LOCPATH=$2
DESTPATH=$3
NOASK=${4:-"false"}
WRITE=0
FILEOUTNAME=$(echo $FILETOPARSE |awk -F'.' '{print $1}')
#FILEOUTNAME="${FILEOUTNAME}"
NUMBEROFLINES=0
SPLIT=0
THREADS=0
SUBTEST="none"
ORIGFILEOUTNAME=""
is_number="no"
WITHMETA=${5:-"false"}


case $FILETOPARSE in
    -h|--help)
      print_help
      ;;
    *)
      echo "Running extract"
      ;;
esac 	
	 
if [ "X${LOCPATH}" = "X" ] 
then
	LOCPATH=`pwd`;
fi 

if [ -f "${LOCPATH}/${FILETOPARSE}" ] 
then 
		echo "File ${LOCPATH}/${FILETOPARSE} OK";  
		echo ".. Calculating the number of line to process:";
		NUMBEROFLINES=$(wc -l ${LOCPATH}/${FILETOPARSE} |awk -F' ' '{print $1}')
		if [ "$DESTPATH" == "" ]; then
		    echo "Invalid destination path |${DESTPATH}|"
		    exit 1
		fi
		ORIGFILEOUTNAME=${DESTPATH}/$FILEOUTNAME/$FILEOUTNAME
		mkdir -p ${DESTPATH}/$FILEOUTNAME/data
	else 
		echo " File ${LOCPATH}/${FILETOPARSE} does not exists";
		exit 1;
fi

ask_confirmation
exract_file
cat << EOF
---------------------------------------------
Process complete $(date +'%Y-%m-%d_%H_%M_%S')
=============================================

EOF
mv ${DESTPATH}/$FILEOUTNAME/*_data.csv ${DESTPATH}/$FILEOUTNAME/data 



