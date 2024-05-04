#! /bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"

MAIN_SCREEN(){

  if [[ $1 ]] 
    then 
       echo -e "\n$1"
  fi
  
  # display available services
  AVAILABLE_SERVICE=$($PSQL "SELECT * FROM services")
  
  #if no service available
  if [[ -z $AVAILABLE_SERVICE ]]
  then
    #send to main screen
    MAIN_SCREEN "I could not find that service. What would you like today?"
  else
  
    echo -e  "\nWelcome to My Salon, how can I help you?"
    echo "$AVAILABLE_SERVICE" | while read SERVICE_ID BAR NAME 
    do
      echo  "$SERVICE_ID) $NAME"
    done
  fi
  ADD_APPOINTMENT
}
ADD_APPOINTMENT(){
  read SERVICE_ID_SELECTED
  SERVICE_ID=$($PSQL "SELECT service_id FROM services WHERE service_id = $SERVICE_ID_SELECTED")
  if [[ -z $SERVICE_ID ]]
    then
      MAIN_SCREEN "I could not find that service. What would you like today?"
    else
      echo -e "\n What's your phone number?"
      read CUSTOMER_PHONE

      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")

        if [[ -z $CUSTOMER_ID ]]
          then
            echo -e "\n What's your name?"
            read CUSTOMER_NAME
            ADD_CUST=$($PSQL "INSERT INTO customers(phone,name) VALUES('$CUSTOMER_PHONE','$CUSTOMER_NAME')")
            CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
            echo -e "\nEnter appointment time"
            read SERVICE_TIME
            ADD_APPOINT=$($PSQL "INSERT INTO appointments(customer_id,service_id,time)
                                  VALUES
                                  ($CUSTOMER_ID,$SERVICE_ID,'$SERVICE_TIME')")
            SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID")
            echo "I have put you down for a $(echo $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME | sed -E 's/^ *| *$//g')."
          else
            echo "Customer found, ENTER appointment time"
            read SERVICE_TIME
            ADD_APPOINT=$($PSQL "INSERT INTO appointments(customer_id,service_id,time)
                                  VALUES
                                  ($CUSTOMER_ID,$SERVICE_ID,'$SERVICE_TIME')")
            CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE customer_id = $CUSTOMER_ID")
            SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID")
            echo "I have put you down for a $(echo $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME | sed -E 's/^ *| *$//g')."
        fi  
  fi
}
MAIN_SCREEN