#!/bin/bash
#MYSQL_HOST=
#MYSQL_USER=
#MYSQL_PASSWORD=
#MYSQL_PORT=3306
#DATABASE=mysql

# Custom command to execute (modify as needed)
CUSTOM_COMMAND="${1:-echo 'Starting MySQL connection monitoring'}"

# Validate that mysql client is available
if ! command -v mysql &> /dev/null; then
    echo "Error: mysql client is not installed or not in PATH"
    exit 1
fi

# Function to test MySQL connection
test_mysql_connection() {
    if [ -z "$PW" ]; then
        mysql -h "$HOST" -P "$PORT" -u "$USER" -e "SELECT 1;" -D "$DATABASE" &> /dev/null
    else
#        mysql -h "$HOST" -P "$PORT" -u "$USER" -p"$PW" -e "SELECT 1;" -D "$DATABASE" 
        mysql -h "$HOST" -P "$PORT" -u "$USER" -p"$PW" -e "SELECT 1;" -D "$DATABASE" &> /dev/null
    fi
}


# Record start time
START_TIME=$(date +%s.%N)
echo "Script started at: $(date)"

# Execute the custom command
echo "Executing custom command: $CUSTOM_COMMAND"
eval "$CUSTOM_COMMAND"
COMMAND_EXIT_CODE=$?

# Set MySQL connection variables
HOST="${MYSQL_HOST:-localhost}"
USER="${MYSQL_USER:-root}"
PW="${MYSQL_PASSWORD:-}"
PORT="${MYSQL_PORT:-3306}"
DATABASE="${MYSQL_DATABASE:-mysql}"


echo "Custom command completed with exit code: $COMMAND_EXIT_CODE"

# Record command completion time
COMMAND_END_TIME=$(date +%s.%N)
COMMAND_DURATION=$(echo "$COMMAND_END_TIME - $START_TIME" | bc)
echo "Custom command took: ${COMMAND_DURATION} seconds"

# Start monitoring MySQL connection
echo "Starting MySQL connection monitoring..."
echo "Target: mysql://$USER@$HOST:$PORT/$DATABASE"

CONNECTION_ESTABLISHED=false
ATTEMPTS=0
MAX_ATTEMPTS=10800  # 3 hour max (10800 seconds)
SLEEP_INTERVAL=1   # Check every second

while [ $ATTEMPTS -lt $MAX_ATTEMPTS ] && [ "$CONNECTION_ESTABLISHED" = false ]; do
    if test_mysql_connection; then
        CONNECTION_ESTABLISHED=true
        CONNECTION_TIME=$(date +%s.%N)
        break
    fi
    
    ATTEMPTS=$((ATTEMPTS + 1))
    if [ $((ATTEMPTS % 60)) -eq 0 ]; then
        echo "Attempt $ATTEMPTS: MySQL server not yet available..."
    fi
    
    sleep $SLEEP_INTERVAL
done

# Calculate and display results
if [ "$CONNECTION_ESTABLISHED" = true ]; then
    TOTAL_DURATION=$(echo "$CONNECTION_TIME - $START_TIME" | bc)
    CONNECTION_WAIT_DURATION=$(echo "$CONNECTION_TIME - $COMMAND_END_TIME" | bc)
    
    echo "=========================================="
    echo "MySQL connection established!"
    echo "Connection successful at: $(date)"
    echo "Total attempts: $ATTEMPTS"
    echo "------------------------------------------"
    echo "Timing results:"
    echo "Command execution time: ${COMMAND_DURATION} seconds"
    echo "MySQL connection wait time: ${CONNECTION_WAIT_DURATION} seconds"
    echo "Total time from start: ${TOTAL_DURATION} seconds"
    echo "=========================================="
else
    echo "Error: Failed to establish MySQL connection after $MAX_ATTEMPTS attempts"
    exit 1
fi

# Optional: Perform additional operations after connection is established
echo "MySQL server is ready for operations"