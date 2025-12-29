#! /usr/bin/bash

#Learning Bash Scripting Language
echo "SCRIPT BY "
echo "            ---CENOZEX "


LOG_DIR="$HOME/Desktop/Logs"
LOG_FILE="$LOG_DIR/user_log_$(date +%F).csv"


#creates a directory id doesnt exist
mkdir -p "$LOG_DIR"

# It creates a csv header if it doesn't exist

if [ ! -f "$LOG_FILE" ]; then
 echo "Date,Username,Address,Contact" > "$LOG_FILE"
fi


#INPUT SECTION

read -p "Enter your username :" username

# Validation : username should not be empty

while [[ -z "$username" ]]; do
 echo "X username should not be empty"
 read -p "Enter your username :" username
done


read -p "Enter your address :" address
read -p "Enter your contact :" contact

#validation : contact should be only numbers

while [[ ! "$contact"=~^[0-9]+$ ]]; do
 echo "X contact should be number only"
 read -p "Enter your contact :" contact 
done


# Now logging part 

echo "$(date '+%Y-%m-%d %H:%M:%S'),$username,$address,$contact" >>"$LOG_FILE"

chmod 600 "$LOG_FILE"

echo "---Data logged Successfully"
echo "---Saved to : $LOG_FILE"



