#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ Welcome to AZ's Hair and Sundry ~~~~~"

MAIN_MENU() {
  if [[ $1 ]] 
  then echo -e "\n$1"  
  fi

  echo -e "\nHow can we help you today?\n"
  echo -e "Select a service by number below:"

  AVAILABLE_SERVICES=$($PSQL "SELECT service_id, name FROM services")
  echo "$AVAILABLE_SERVICES" | while read SERVICE_ID BAR NAME
    do echo "$SERVICE_ID) $NAME"
  done
  
  read SERVICE_ID_SELECTED
  if [[ ! $SERVICE_ID_SELECTED =~ [1-5]$ ]]
  then MAIN_MENU "Please follow the instructions and enter a value from the list."
  else APPT_MENU
  fi
}

APPT_MENU() {
  if [[ $1 ]]
  then echo -e "\n$1"
  fi

  echo -e "\nGreat choice! You really need that done.\n"
  echo Please provide your phone number:
  read CUSTOMER_PHONE
  # insert regex for phone number
  if [[ ! $CUSTOMER_PHONE =~ [0-9]{3}?-?[0-9]{3}-?[0-9]{4}$ ]]
    then APPT_MENU "Please enter a valid phone number."
    else 
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
    if [[ -z $CUSTOMER_NAME ]]
    then
    echo -e "First time. Welcome to our shop!\nWhat's your name?"
    read CUSTOMER_NAME
    INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
    else
    echo -e "\nWelcome back, $(echo $CUSTOMER_NAME | sed -E 's/^ +$//g')!"
    fi  
    SET_TIME
  fi
  }

SET_TIME() {
  if [[ $1 ]]
  then echo -e "\n$1"
  fi
  
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
  SERVICE=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")

  echo -e "\nWhat time works for you?"
  read SERVICE_TIME
  
  # insert appointment
  INSERT_SERVICE_TIME=$($PSQL "INSERT INTO appointments(time, customer_id, service_id) VALUES('$SERVICE_TIME', $CUSTOMER_ID, $SERVICE_ID_SELECTED)")
    
  echo -e "\nI have put you down for a $(echo $SERVICE | sed -E 's/^ +$//g') at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed -E 's/^ +$//g')."
 }

MAIN_MENU