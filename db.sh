#!/bin/bash

function create_database {
    if [[ $dbName =~ ^[A-Za-z_][A-Za-z0-9]*$ ]]; then
        if [[ -d ./DataBase/$dbName ]]; then
            dialog --title "Create Database Message" --msgbox "Database $dbName Already Exists" 8 45
        else
            mkdir ./DataBase/$dbName
            dialog --title "Create Database Message" --msgbox "Database $dbName Successfully Created" 8 45
        fi
    else
        dialog --title "Create Database Message" --msgbox "Database Name Validation Error" 8 45
    fi
}

function select_Database {
    if [[ $dbName =~ ^[A-Za-z_][A-Za-z0-9]*$ ]]; then
        if [[ -d ./DataBase/$dbName ]]; then
            dialog --title "Connect to Database" --msgbox "Connected Successfully" 8 45
            tableMainMenu
        else
            dialog --title "Connect to Database" --msgbox "Database Doesn't Exist" 8 45
            mainMenu
        fi
    else
        dialog --title "Connect to Database" --msgbox "Database Name Validation Error" 8 45
    fi
}


function drop_database {
    if [[ $dbName =~ ^[A-Za-z_][A-Za-z0-9]*$ ]]; then
        if [[ -d ./DataBase/$dbName ]]; then
            if (dialog --title "Are You Sure?" --yesno "Are You Sure You Want to Delete $dbName Database?" 8 45); then
                rm -r ./DataBase/$dbName
                dialog --title "Delete Database Message" --msgbox "Database Deleted!" 8 45
            else
                dialog --title "Delete Database Message" --msgbox "Operation Canceled" 8 45
            fi
        else
            dialog --title "Delete Database Message" --msgbox "Database $dbName Doesn't Exist" 8 45
        fi
    else
        dialog --title "Delete Database Message" --msgbox "Database Name Validation Error" 8 45
    fi
}

function rename_Database {
    if [[ -d ./DataBase/$currentName ]]; then
        newName=$(dialog --title "Rename Database" --inputbox "Enter Database New Name: " 8 45 3>&1 1>&2 2>&3)
        if [[ -d ./DataBase/$newName ]]; then
            dialog --title "Rename Database Message" --msgbox "Cannot Rename Database, $dbName Already Exists" 8 45
        else
            if [[ $newName =~ ^[A-Za-z_][A-Za-z0-9]*$ ]]; then
                mv ./DataBase/$currentName ./DataBase/$newName
                dialog --title "Rename Database Message" --msgbox "Database Renamed Successfully" 8 45
            else
                dialog --title "Rename Database Message" --msgbox "Database Name Validation Error" 8 45
            fi
        fi
    else
        dialog --title "Rename Database Message" --msgbox "Database Doesn't Exist" 8 45
    fi
}

function create_table {
    if [[ $tableName =~ ^[A-Za-z_][A-Za-z0-9]*$ ]]; then
        if [[ -f ./DataBase/$dbName/$tableName ]]; then
            dialog --title "Create Table Message" --msgbox "Table $tableName Already Exists" 8 45
        else
            columns=$(dialog --title "Columns Number" --inputbox "Enter Number of Columns" 8 45 3>&1 1>&2 2>&3)
            touch ./DataBase/$dbName/$tableName

            i=1
            datatype=""
            isPrimary=""
            primarykeyMenu="2"
            separator="|"
            tableInfo=$colName$separator$datatype$separator$isPrimary

            while [ $i -le $columns ]; do
                colName=$(dialog --title "Column Name" --inputbox "Enter Column $i Name" 8 45 3>&1 1>&2 2>&3)
                datatypeMenu=$(dialog --title "Data Type Menu" --menu "Select Data Type" 15 60 4 \
                    "1" "int" \
                    "2" "str" \
                    "3" "boolean" 3>&1 1>&2 2>&3)
                case $datatypeMenu in
                1)
                    datatype="int"
                    ;;
                2)
                    datatype="str"
                    ;;
                3)
                    datatype="boolean"
                    ;;
                esac
                if [[ $primarykeyMenu == "2" ]]; then
                    primarykeyMenu=$(dialog --title "Primary Key Menu" --menu "Is column primary key?" 15 60 4 \
                        "1" "yes" \
                        "2" "no" 3>&1 1>&2 2>&3)
                    case $primarykeyMenu in
                    1)
                        isPrimary="yes"
                        ;;
                    2)
                        isPrimary="no"
                        ;;
                    esac
                fi

                if [[ $i -eq $columns ]]; then
                    echo $colName$separator >>./DataBase/$dbName/$tableName
                    echo $colName$separator$datatype$separator$isPrimary >>./DataBase/$dbName/.$tableName
                else
                    echo -n $colName$separator >>./DataBase/$dbName/$tableName
                    echo $colName$separator$datatype$separator$isPrimary$separator >>./DataBase/$dbName/.$tableName
                fi
                ((i++))
                isPrimary="no"
            done
            dialog --title "Create Table Message" --msgbox "Table $tableName Successfully Created" 8 45
        fi
    else
        dialog --title "Create Table Message" --msgbox "Name Validation Error" 8 45
    fi
}

function delete_from_table {
    if [[ $tableName =~ ^[A-Za-z_][A-Za-z0-9]*$ ]]; then
        if ! [[ -f ./DataBase/$dbName/$tableName ]]; then
            dialog --title "Error Message" --msgbox "Table Not Found" 8 45
            tableMainMenu
        else
            colname=$(dialog --title "Delete From Table" --inputbox "Enter Condition Column Name" 8 45 3>&1 1>&2 2>&3)
            checkcolumnfound=$(awk 'BEGIN{FS="|"}{if(NR==1){for(i=1;i<=NF;i++){if($i=="'$colname'") print i}}}' ./DataBase/$dbName/$tableName)
            if [[ $checkcolumnfound == "" ]]; then
                dialog --title "Error Message" --msgbox "Column Not Found" 8 45
            else
                value=$(dialog --title "Delete From Table" --inputbox "Enter Condition Value" 8 45 3>&1 1>&2 2>&3)
                recordNo=$(awk 'BEGIN{FS="|"}{if ($'$checkcolumnfound'=="'$value'") print NR}' ./DataBase/$dbName/$tableName)
                if [[ $recordNo == 1 ]]; then
                    dialog --title "Error Message" --msgbox "Value Not Found" 8 45
                else
                    if [[ $recordNo == "" ]]; then
                        dialog --title "Error Message" --msgbox "Record Doesn't Exist" 8 45
                    else
                        sed -i ''$recordNo'd' ./DataBase/$dbName/$tableName
                        dialog --title "Record" --msgbox "Record Deleted Successfully" 8 45
                    fi
                fi
            fi
        fi
    else
        dialog --title "Error Message" --msgbox "Table Name Validation Error" 8 45
    fi
}

function drop_table {
    if [[ $tableName =~ ^[A-Za-z]{1}+([A-Za-z0-9]*)$ ]]; then
        if [[ -f ./DataBase/$dbName/$tableName ]]; then
            if (dialog --title "Are You Sure?" --yesno "Are You Sure You Want to Delete $tableName Table?" 8 45); then
                rm ./DataBase/$dbName/$tableName
                rm ./DataBase/$dbName/.$tableName
                dialog --title "Delete Table Message" --msgbox "Table Deleted!" 8 45
            else
                dialog --title "Delete Table Message" --msgbox "Operation Canceled" 8 45
            fi
        else
            dialog --title "Delete Table Message" --msgbox "Table $tableName Doesn't Exist" 8 45
        fi
    else
        dialog --title "Delete Table Message" --msgbox "Table Name Doesn't Meet Minimum Requirements" 8 45
    fi
}

function insert_into_table {
    if [[ $tableName =~ ^[A-Za-z_][A-Za-z0-9]*$ ]]; then
        if [[ -f ./DataBase/$dbName/$tableName ]]; then
            numberOfColumns=$(awk 'END {print NR}' ./DataBase/$dbName/.$tableName)
            separator="|"
            for ((i = 1; i <= $numberOfColumns; i++)); do
                checkcolname=$(awk 'BEGIN {FS="|"}{if ( NR=='$i' ) print $1 }' ./DataBase/$dbName/.$tableName)
                checkdatatype=$(awk 'BEGIN {FS="|"}{if ( NR=='$i' ) print $2 }' ./DataBase/$dbName/.$tableName)
                checkisprimary=$(awk 'BEGIN {FS="|"}{if ( NR=='$i' ) print $3 }' ./DataBase/$dbName/.$tableName)
                record=$(dialog --title "Your Data" --inputbox "Enter data for $checkcolname with data type ($checkdatatype)" 8 45 3>&1 1>&2 2>&3)

                # Validate data type
                if [[ $checkdatatype == "int" ]]; then
                    while ! [[ $record =~ ^[0-9]+$ ]]; do
                        dialog --title "Error Message" --msgbox "Not an integer, Enter Record Again" 8 45
                        record=$(dialog --title "Your Data" --inputbox "Enter data for $checkcolname with data type ($checkdatatype)" 8 45 3>&1 1>&2 2>&3)
                    done
                elif [[ $checkdatatype == "str" ]]; then
                    while ! [[ $record =~ ^[A-Za-z]+$ ]]; do
                        dialog --title "Error Message" --msgbox "Not a string, Enter Record Again" 8 45
                        record=$(dialog --title "Your Data" --inputbox "Enter data for $checkcolname with data type ($checkdatatype)" 8 45 3>&1 1>&2 2>&3)
                    done
                elif [[ $checkdatatype == "boolean" ]]; then
                    while ! [[ $record = "true" || $record = "false" || $record = "TRUE" || $record = "FALSE" || $record = "True" || $record = "False" || $record = "yes" || $record = "no" ]]; do
                        dialog --title "Error Message" --msgbox "Not a boolean; Enter true, false, TRUE, FALSE, True, False, yes, or no only" 8 45
                        record=$(dialog --title "Your Data" --inputbox "Enter data for $checkcolname with data type ($checkdatatype)" 8 45 3>&1 1>&2 2>&3)
                    done
                fi

                # Primary key validation
                if [[ $checkisprimary == "yes" ]]; then
                    while true; do
                        if awk -F"|" -v col="$i" -v val="$record" 'NR > 1 && $col == val { exit 1 }' ./DataBase/$dbName/$tableName; then
                            break
                        else
                            dialog --title "Error Message" --msgbox "Primary key must be unique. '$record' already exists." 8 45
                            record=$(dialog --title "Your Data" --inputbox "Enter data for $checkcolname with data type ($checkdatatype)" 8 45 3>&1 1>&2 2>&3)
                        fi
                    done
                fi

                # Append the record to the table
                if ! [[ $i == $numberOfColumns ]]; then
                    echo -n $record$separator >>./DataBase/$dbName/$tableName
                else
                    echo $record >>./DataBase/$dbName/$tableName
                    dialog --title "Success Message" --msgbox "Your record inserted successfully" 8 45
                fi
            done
        else
            dialog --title "Error Message" --msgbox "Table Not Found" 8 45
            tableMainMenu
        fi
    else
        dialog --title "Error Message" --msgbox "Table Name Validation Error" 8 45
    fi
}



function selectAll {
    table=$(cat ./DataBase/$dbName/$tableName)
    dialog --title "Table Records" --msgbox "$table" 35 70
}

function select_column {
    columnName=$(dialog --title "Table Records" --inputbox "Enter Column Name" 8 45 3>&1 1>&2 2>&3)
    checkColumnFound=$(awk 'BEGIN{FS="|"}{if(NR==1){for(i=1;i<=NF;i++){if($i=="'$columnName'") print i}}}' ./DataBase/$dbName/$tableName)
    if [[ $checkColumnFound == "" ]]; then
        dialog --title "Error Message" --msgbox "Column doesn't exist" 8 45
    else
        columnrecord=$(awk -F"|" '{print $"'$checkColumnFound'"}' ./DataBase/$dbName/$tableName)
        dialog --title "Table Column Record" --msgbox "$columnrecord" 35 70
    fi
}


function select_table_where {
    columnName=$(dialog --title "Table Records" --inputbox "Enter Column Name" 8 45 3>&1 1>&2 2>&3)
    checkColumnFound=$(awk 'BEGIN{FS="|"}{if(NR==1){for(i=1;i<=NF;i++){if($i=="'$columnName'") print i}}}' ./DataBase/$dbName/$tableName)
    if [[ $checkColumnFound == "" ]]; then
        dialog --title "Error Message" --msgbox "Column doesn't exist" 8 45
    else
        value=$(dialog --title "Column Record" --inputbox "Enter Value To Search For" 8 45 3>&1 1>&2 2>&3)
        record=$(awk 'BEGIN{FS="|"}{if ($'$checkColumnFound'=="'$value'")  print $0}' ./DataBase/$dbName/$tableName)
        if [[ $record == "" ]]; then
            dialog --title "Error Message" --msgbox "Record not found" 8 45
        else
            dialog --title "Record" --msgbox "$record" 15 45
        fi
    fi
}

function update_table {
    if [[ $tableName =~ ^[A-Za-z_][A-Za-z0-9]*$ ]]; then
        if [[ -f ./DataBase/$dbName/$tableName ]]; then
            columnName=$(dialog --title "Table Records" --inputbox "Enter Column Name" 8 45 3>&1 1>&2 2>&3)
            checkColumnFound=$(awk 'BEGIN{FS="|"}{if(NR==1){for(i=1;i<=NF;i++){if($i=="'$columnName'") print i}}}' ./DataBase/$dbName/$tableName)

            if [[ $checkColumnFound == "" ]]; then
                dialog --title "Error Message" --msgbox "Column doesn't exist" 8 45
                tableMainMenu
            else
                condvalue=$(dialog --title "Column Record" --inputbox "Enter Your Condition Value" 8 45 3>&1 1>&2 2>&3)
                condrecordNo=$(awk 'BEGIN{FS="|"}{if ($'$checkColumnFound'=="'$condvalue'") print $'$checkColumnFound'}' ./DataBase/$dbName/$tableName)
                recordNo=$(awk 'BEGIN{FS="|"}{if ($'$checkColumnFound'=="'$condvalue'") print NR}' ./DataBase/$dbName/$tableName)
                if [[ $condrecordNo == "" ]]; then
                    dialog --title "Error Message" --msgbox "This value doesn't Exist" 8 45
                else
                    if [[ $recordNo == 1 ]]; then
                        dialog --title "Error Message" --msgbox "This record can't be updated (header row)" 8 45
                        tableMainMenu
                    else
                        field=$(dialog --title "Field Name" --inputbox "Enter field name" 8 45 3>&1 1>&2 2>&3)
                        checkfieldfound=$(awk 'BEGIN{FS="|"}{if(NR==1){for(i=1;i<=NF;i++){if($i=="'$field'") print i}}}' ./DataBase/$dbName/$tableName)

                        if [[ $checkfieldfound == "" ]]; then
                            dialog --title "Error Message" --msgbox "Field Not Found" 8 45
                            tableMainMenu
                        else
                            newrecord=$(dialog --title "Field Name" --inputbox "Enter new record" 8 45 3>&1 1>&2 2>&3)

                            # Check if the field being updated is a primary key
                            isPrimary=$(awk 'BEGIN{FS="|"}{if(NR=='$checkfieldfound') print $3}' ./DataBase/$dbName/.$tableName)
                            if [[ $isPrimary == "yes" ]]; then
                                # Ensure the new primary key value is unique
                                while true; do
                                    if awk -F"|" -v col="$checkfieldfound" -v val="$newrecord" 'NR > 1 && $col == val { exit 1 }' ./DataBase/$dbName/$tableName; then
                                        break
                                    else
                                        dialog --title "Error Message" --msgbox "Primary key must be unique. '$newrecord' already exists." 8 45
                                        newrecord=$(dialog --title "Field Name" --inputbox "Enter new record" 8 45 3>&1 1>&2 2>&3)
                                    fi
                                done
                            fi

                            # Update the record
                            oldrecord=$(awk 'BEGIN{FS="|"}{if(NR=='$recordNo'){for(i=1;i<=NF;i++){if(i=='$checkfieldfound') print $i}}}' ./DataBase/$dbName/$tableName)
                            sed -i ''$recordNo's/'$oldrecord'/'$newrecord'/g' ./DataBase/$dbName/$tableName
                            dialog --title "Record" --msgbox "Record Updated Successfully" 8 45
                        fi
                    fi
                fi
            fi
        else
            dialog --title "Table Records" --msgbox "Table Doesn't Exist" 8 45
            tableMainMenu
        fi
    else
        dialog --title "Table Records" --msgbox "Table Name Doesn't Meet Minimum Requirements" 8 45
        tableMainMenu
    fi
}

# Main loop
if ! [[ -d ./DataBase ]]; then
    mkdir ./DataBase
fi

function mainMenu() {
    mainMenu=$(dialog --title "DBMS Menu" --menu "Choose an option" 15 60 6 \
        "1" "Select Database" \
        "2" "Create Database" \
        "3" "Rename Database" \
        "4" "Drop Database" \
        "5" "Display Databases" \
        "6" "Exit" 3>&1 1>&2 2>&3)

   case $mainMenu in
    1)
        options=$(ls ./DataBase)
        dialog_options=""
        index=1
        declare -A option_map
        for option in $options; 
        do
            dialog_options+="$index $option "
            option_map[$index]=$option
            index=$((index + 1))
        done
        selection=$(dialog --title "Connect to Database" --menu "Choose an option" 25 50 $((index - 1)) $dialog_options 3>&1 1>&2 2>&3)
        clear
        
        if [ -n "$selection" ]; then
            dbName=${option_map[$selection]}
            echo "Selected Database: $dbName" # Debugging line
            if [[ -d ./DataBase/$dbName ]]; then
                echo "Database $dbName exists" # Debugging line
                select_Database
                mainMenu
            else
                echo "Database $dbName does not exist" # Debugging line
            fi
        else
            echo "No selection made."
        fi
        ;;

    2)
        dbName=$(dialog --title "Create Database" --inputbox "Enter Database Name: " 8 45 3>&1 1>&2 2>&3)
        create_database
        mainMenu
        ;;
    3)
        currentName=$(dialog --title "Rename Database" --inputbox "Enter Database Current Name: " 8 45 3>&1 1>&2 2>&3)
        rename_Database
        mainMenu
        ;;
    4)
        dbName=$(dialog --title "Delete Database" --inputbox "Enter Database Name: " 8 45 3>&1 1>&2 2>&3)
        drop_database
        mainMenu
        ;;
    5)
        dataBasse=$(ls ./DataBase)
        dialog --title "List of Databases" --msgbox "$dataBasse" 30 45
        mainMenu
        ;;
    6)
        exit
        ;;
    esac
}


function tableMainMenu() {
    tableMainMenu=$(dialog --title "Table Menu" --menu "Choose an option" 25 50 9 \
        "1" "Create Table" \
        "2" "List Tables" \
        "3" "Drop Table" \
        "4" "Insert into Table" \
        "5" "Select From Table" \
        "6" "Delete From Table" \
        "7" "Update Table" \
        "8" "Back to Main Menu" \
        "9" "Exit" 3>&1 1>&2 2>&3)

    case $tableMainMenu in
    1)
        tableName=$(dialog --title "Create Table" --inputbox "Enter Table Name: " 8 45 3>&1 1>&2 2>&3)
        create_table
        tableMainMenu
        ;;
    2)
        tables=$(ls ./DataBase/$dbName)
        dialog --title "List of Tables in Database $dbName" --msgbox "$tables" 30 45
        tableMainMenu
        ;;
    3)
        select_table "Drop Table" "drop_table"
        ;;
    4)
        select_table "Insert Into Table" "insert_into_table"
        ;;
    5)
        select_table "Select From Table" "tableSelectMenu"
        ;;
    6)
        select_table "Delete from Table" "delete_from_table"
        ;;
    7)
        select_table "Update Table" "update_table"
        ;;
    8)
        mainMenu
        ;;
    9)
        exit
        ;;
    esac
}

function select_table() {
    local title="$1"
    local action="$2"

    tables=$(ls ./DataBase/$dbName)
    dialog_options=""
    index=1
    declare -A option_map
    for table in $tables; 
    do
        dialog_options+="$index $table "
        option_map[$index]=$table
        index=$((index + 1))
    done
    selection=$(dialog --title "$title" --menu "Choose a table" 25 50 $((index - 1)) $dialog_options 3>&1 1>&2 2>&3)
    clear
    if [ -n "$selection" ]; then
        tableName=${option_map[$selection]}
        eval $action
        tableMainMenu
    else
        echo "No selection made."
    fi
}

function tableSelectMenu() {
    tableSelectMenu=$(dialog --title "Select From Table Menu" --menu "Choose an option" 25 50 6 \
        "1" "Select All Columns" \
        "2" "Select Specific Column" \
        "3" "Select With Specific Value" \
        "4" "Back to Table Menu" \
        "5" "Back to Main Menu" \
        "6" "Exit" 3>&1 1>&2 2>&3)

    case $tableSelectMenu in
    1)
        selectAll
        tableSelectMenu
        ;;
    2)
        select_column
        tableSelectMenu
        ;;
    3)
        select_table_where
        tableSelectMenu
        ;;
    4)
        tableMainMenu
        ;;
    5)
        mainMenu
        ;;
    6)
        exit
        ;;
    esac
}

mainMenu