#!/bin/bash

# Log directory
log_dir="/var/log"


shell_monitor="$log_dir/shell_monitor.log"


# Log date and time
log_datetime() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')]"
}

monitor_usage() {
  cpu_usage=$(top -b -n 1 | grep "%Cpu(s)" | awk '{print $2}')
  memory_usage=$(free -m | awk 'NR==2 {print $3}')
  file_handles=$(lsof -w| wc -l)
  tcp_connection_status=$(netstat -ant | awk '/^tcp/ {++S[$NF]} END {for(a in S) print a":"S[a]}'|sed -e ':a;N;$!ba;s/\n/,/g')
  echo "$(log_datetime) CPU: $cpu_usage%, Memory: $memory_usage MB, File Handles: $file_handles | $tcp_connection_status" >> $shell_monitor
}

monitor_usage
