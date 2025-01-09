#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"
#Service name and customer name retrieved from database may contain leading spaces due to --tuples-only flag.

#Function to display services
MAIN_MENU() {
  #Read and list services from database
  SERVICES=$($PSQL "SELECT service_id, name FROM services")
  echo "$SERVICES" | while IFS=" | " read SERVICE_ID SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done
}

#Function for appointment
SCHEDULE_APPOINTER() {
  #A loop that handles repeated invalid inputs
  while true; do
    MAIN_MENU
    read SERVICE_ID_SELECTED
    SERVICE_NAME_QUERY=$($PSQL "SELECT name FROM services WHERE service_id='$SERVICE_ID_SELECTED'")
    SERVICE_NAME=$(echo "$SERVICE_NAME_QUERY" | sed -E 's/^ *| *$//g')

    #if invalid service id input
    if [[ -z $SERVICE_NAME ]]
    then
      echo -e "\nIt seems like that service does not exist, please choose another one."
    else
      break
    fi
  done
  echo -e "\nWhat is your phone number?"
  read CUSTOMER_PHONE
  CUSTOMER_NAME_QUERY=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
  CUSTOMER_NAME=$(echo "$CUSTOMER_NAME_QUERY" | sed -E 's/^ *| *$//g')
  if [[ -z $CUSTOMER_NAME ]]
  then
    echo -e "\nIt seems like you are a new customer. What is your name?"
    read CUSTOMER_NAME
    INSERT_CUSTOMER_QUERY=$($PSQL "INSERT INTO customers (name, phone) VALUES('$CUSTOMER_NAME','$CUSTOMER_PHONE')")
  fi
  echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
  read SERVICE_TIME
  INSERT_APPOINTMENT_QUERY=$($PSQL "INSERT INTO appointments (customer_id, service_id, time) VALUES ('$CUSTOMER_ID','$SERVICE_ID_SELECTED','$SERVICE_TIME')")
  echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
}

MAIN() {
  echo -e "\n~~~~~ MY SALON ~~~~~"
  echo -e "\nWelcome to My Salon, how can I help you?\n"
  SCHEDULE_APPOINTER
}

MAIN