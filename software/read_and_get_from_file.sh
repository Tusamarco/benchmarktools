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

FILETOPARSE=$1
LOCPATH=$2
WRITE=0
FILEOUTNAME=$(echo $FILETOPARSE |awk -F'.' '{print $1}')
#FILEOUTNAME="${FILEOUTNAME}"
NUMBEROFLINES=0
SPLIT=0
THREADS=0
SUBTEST="none"
ORIGFILEOUTNAME=""
is_number="no"

	if [ "X${LOCPATH}" = "X" ] 
	then
		LOCPATH=`pwd`;
	fi 

	if [ -f "${LOCPATH}/${FILETOPARSE}" ] 
	then 
			echo "File ${LOCPATH}/${FILETOPARSE} OK";  
            echo ".. Calculating the number of line to process:";
            NUMBEROFLINES=$(wc -l ${LOCPATH}/${FILETOPARSE} |awk -F' ' '{print $1}')
            ORIGFILEOUTNAME=${LOCPATH}/$FILEOUTNAME/$FILEOUTNAME
            mkdir -p ${LOCPATH}/$FILEOUTNAME/data
		else 
			echo " File ${LOCPATH}/${FILETOPARSE} does not exists";
			exit 1;
	fi


ask_confirmation(){
  echo "============================================="
  echo "FILE To Parse ${FILETOPARSE}"
  echo "Number of lines ${NUMBEROFLINES}"
  echo "Local Path  ${LOCPATH}"
  echo "Resulting filename HEAD ${FILEOUTNAME}"
  echo "============================================="

  read -p "Should continue? [y/n] " -n 1 -r
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

exract_file(){
	
	local type_of_output=""
	i=0
    WRITE=0 
	OLDDATE="NEW"
	COUNTER=0
	SUMMARYLINE1=false

	while read -r LINE
	do
    if [[ $LINE =~ "SUBTEST" ]]; then
	    SUBTEST=$(echo $LINE|sed -e 's/ //gi'|awk -F':' '{print $2}')
	    SUMMARYLINE1=true
	fi

    if [[ $LINE =~ "THREADS" ]] && [ ! "$SUBTEST" == "none" ]; then
	    THREADS=$(echo $LINE|sed -e 's/ //gi'|awk -F'=' '{print $2}')
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
	
	if [ $i -gt 500 ]
	then
         echo "At ${COUNTER} Line"
 	     ((COUNTER=COUNTER+i))
	     i=0
	 fi
	done < ${LOCPATH}/${FILETOPARSE}
}

print_help(){

echo " read_and_get_from_file.sh <FILE_name> <PATH> "

}

case $FILETOPARSE in
    -h|--help)
      print_help
      ;;
    *)
      echo "Running extract"
      ask_confirmation
      exract_file
      mv ${ORIGFILEOUTNAME}_*_data.csv ${LOCPATH}/$FILEOUTNAME/data 
      ;;
  esac 	
	 
