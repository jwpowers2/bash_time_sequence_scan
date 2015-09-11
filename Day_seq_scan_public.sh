#!/bin/bash

#### This program will parse compressed files in the current directory, parse for epoch time, 
#### convert it to date and then check for out of sequence entries
#### the list of dates for each file is stored in a text file to provide for a high number of 
#### entries.  If an error is found, it is sent to an error log and when the sequence check is 
#### complete for each file, the text store file is deleted

# function one will create a sequence error log in the current directory

make_error_log () {
        touch seq_error.log
}

# function two will create a note in the log showing parsing is beginning on a new file

start_hour () { 
                echo >> seq_error.log "*********************** BEGIN $i **************************"
}

# function three creates text file, unzips target file, parses for time, converts time (unix to date)
# then concats hour and minute together 

parse_date () {
        echo "creating " $i.date_file.txt
        zcat $1 | awk -F, '{print $3}' | awk -F: '{print $2}' | awk '{printf "%s -- %s\n", strftime("%c",$1),$0}' | awk '{print $5}' | awk -F: '{print $1}' | sed 's/^0//' >> $i.date_file.txt
}

# function four will check sequence in the text file and send notes to error log  if errors exist

check_sequence () {
        for line in $(cat $1)
        do
                previous=0
                if [[ $line < $previous ]]
                then
                        echo >> seq_error.log "line is greater than previous for [ $i ] during hour [ $line ]"
                fi
                previous=$line
        done
}

# function five will delete the text file used to store parsed dates 

delete_date () {
        rm $1
        echo "deleted " $1
}

# function six will denote in the error log when the program is finished with the file

end_hour () {
                echo >> seq_error.log "**************************** END HOUR $i *****************************"
}

 for i in *
 do
        if [[ -f $i ]]
        then
                if [[ $i == *.gz ]]
                then
                        start_hour
                        make_error_log
                        parse_date $i
                        check_sequence $i.date_file.txt
                        delete_date $i.date_file.txt
                        end_hour
                fi
        fi
done
