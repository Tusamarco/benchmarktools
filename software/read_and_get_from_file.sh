#! /bin/bash 
#
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
            mkdir -p ${LOCPATH}/$FILEOUTNAME/
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
#        echo $LINE
	    THREADS=$(echo $LINE|sed -e 's/ //gi'|awk -F'=' '{print $2}')
#	    echo "DEBUG THREADS: ${THREADS}"
	fi
    
    if [[ $LINE =~ "Threads started" ]] && [ $THREADS > 0 ]; then
       type_of_output="data"
       WRITE=1 
       workingfile=${ORIGFILEOUTNAME}_${SUBTEST}_${THREADS}_${type_of_output}.csv
       #we go ahead one empty line to go for next series of data
       read -r LINE2
       read -r LINE3
       LINE=${LINE3} 
       echo "DEBUG DATA |$LINE|$LINE2|"
    fi    

# 	if  [ $WRITE -eq 1 ] &&  [[ $LINE =~ $STOPDELIMITER ]]
# 	then
# 		WRITE=0
#         if  [ $SPLIT -eq 1 ] 
#         then
#             ((SPLITCOUNTER=$SPLITCOUNTER+1))
#             FILEOUTNAME=${ORIGFILEOUTNAME}_${SPLITCOUNTER}_data.txt
#         fi
# 	fi


   if [[ $LINE =~ "Latency" ]]; then
       type_of_output="histogram"
       WRITE=1 
       workingfile=${ORIGFILEOUTNAME}_${SUBTEST}_${type_of_output}.txt
   fi

   if [[ $LINE =~ "TEST SUMMARY" ]]; then
       type_of_output="summary"
       WRITE=0 
       workingfile=${ORIGFILEOUTNAME}_${SUBTEST}_${type_of_output}.csv
       read -r LINE2 
       if [ $SUMMARYLINE1 == true ];then
           echo $LINE2 >> ${workingfile}
           SUMMARYLINE1=false
       fi
       read -r LINE3
#       echo "DEBUG summary |$LINE|$LINE2|$LINE3|"
       echo $LINE3 >> ${workingfile}
       #workingfile=""
   fi
#   echo "DEBUG: ${type_of_output}"
   if [[ $LINE =~ "BLOCK: [END]" ]]; then
    	WRITE=0
    	SUBTEST="none"
    	THREADS=0
    	workingfile=""	
    fi
   
	if [ $WRITE == 1 ]; then
	    echo "WRITE IS ON"
		if [ "${type_of_output}" == "data" ]; then
	  	    to_check=$(echo $LINE|awk -F',' '{print $1}')
            #we check if the line has numbers of any text because error in the last case we stop writing 
            check_number $to_check
	  	    if [ "$is_number" == "yes" ]; then
		  		echo $LINE >> ${workingfile}
		  	else
		  		WRITE=0
		  		type_of_output=""
		  		#workingfile=""
		  	fi
		else
		  	echo $LINE >> ${workingfile}
	  	fi
	fi
	
	((i=i+1))
	
	if [ $i > 1000000 ]
	then
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
      ;;
  esac 	
	 
