#!/bin/bash

# Check if two arguments are provided
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <IP_ADDRESS> <TIME_IN_MS>"
    exit 1
fi

IP_ADDRESS=$1
TIME_IN_MS=$2
START_TIME=$(date +%s)
SHORTEST_TIME=999999
LONGEST_TIME=0
TOTAL_COUNTER=0
LONG_COUNTER=0

# Function to print in red color
print_red() {
    echo -e "\033[0;31m$1\033[0m"
}

print_cyan(){
    echo -e "\033[0;36m$1\033[0m"
}

print_yellow() {
    echo -e "\033[0;33m$1\033[0m"
}

# Function to display statistics upon exit
display_stats() {
    END_TIME=$(date +%s)
    RUN_TIME=$((END_TIME-START_TIME))
    echo ""
    echo -e "\e[1;33;4;44mTotal running time: $((RUN_TIME/60)) minute(s)\e[0m"
    print_cyan "Shortest response time: $SHORTEST_TIME ms"
    print_red "Longest response time: $LONGEST_TIME ms"
    print_yellow "Responses exceed $TIME_IN_MS ms: \033[1m$LONG_COUNTER\033[1m of $TOTAL_COUNTER"
    exit 0
}

# Trap SIGINT to display statistics before exiting
trap display_stats SIGINT

# Ping the IP address indefinitely and print the output
while true; do
    # Get the ping response
    PING_RESPONSE=$(ping -c 1 $IP_ADDRESS | grep 'time=')
    # Increase the TOTAL_COUNTER by 1
    ((TOTAL_COUNTER++))
    # Check if the ping response contains a time value
    if [[ $PING_RESPONSE =~ time=([0-9.]+) ]]; then
        RESPONSE_TIME=${BASH_REMATCH[1]}
        
        # Update shortest and longest response times
        if [ "$(echo "$RESPONSE_TIME < $SHORTEST_TIME" | bc)" -eq 1 ]; then
            SHORTEST_TIME=$RESPONSE_TIME
        fi
        if [ "$(echo "$RESPONSE_TIME > $LONGEST_TIME" | bc)" -eq 1 ]; then
            LONGEST_TIME=$RESPONSE_TIME
        fi

        # Check if the response time is greater than the specified time
        if [ "$(echo "$RESPONSE_TIME > $TIME_IN_MS" | bc)" -eq 1 ]; then
            # Print the response line in red color
            print_red "$PING_RESPONSE"
            #Increase LONG_COUNTER by 1
            ((LONG_COUNTER++))
            # Play a short beep sound using the beep command            
            beep -f 1000 -l 100
        else
            echo "$PING_RESPONSE"
        fi
    else
        print_yellow "✘: Host is not reachable or response time is not available."
    fi

    # Wait for a second before the next ping
    sleep 1
done
