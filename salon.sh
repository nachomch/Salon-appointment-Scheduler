#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"
echo -e "\n~~~ Welcome to our salon ~~~\n"
SERVICE_MENU()
{
  if [[ ! -z $1 ]]
  then
    echo -e "\n$1\n"
  fi
  echo "Which service would you like to appoint?"
  SERVICES=$($PSQL "SELECT service_id, name FROM services")
  echo "$SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done
  read SERVICE_ID_SELECTED
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
  if [[ -z $SERVICE_NAME ]]
  then
    SERVICE_MENU "Sorry, we don't offer that service"
  else
    echo -e "\nPlease, enter your phone number:"
    read CUSTOMER_PHONE
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
    if [[ -z $CUSTOMER_ID ]]
    then
      echo -e "\nPlease, enter your name:"
      read CUSTOMER_NAME
      NEW_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name,phone) VALUES ('$CUSTOMER_NAME','$CUSTOMER_PHONE')")    
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
      echo -e "\n\nYour id is $CUSTOMER_ID"
    else
      CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE customer_id=$CUSTOMER_ID")
    fi
    echo -e "\nPlease, enter the time you want to reserve"
    read SERVICE_TIME
    NEW_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id,time) VALUES ($CUSTOMER_ID,$SERVICE_ID_SELECTED,'$SERVICE_TIME')")
    SERVICE_NAME_FORMATTED=$(echo $SERVICE_NAME | sed 's/^ *| *$//g')
    SERVICE_TIME_FORMATTED=$(echo $SERVICE_TIME | sed 's/^ *| *$//g')
    CUSTOMER_NAME_FORMATTED=$(echo $CUSTOMER_NAME | sed 's/^ *| *$//g')
    echo -e "\nI have put you down for a $SERVICE_NAME_FORMATTED at $SERVICE_TIME_FORMATTED, $CUSTOMER_NAME_FORMATTED."
  fi
}
SERVICE_MENU
