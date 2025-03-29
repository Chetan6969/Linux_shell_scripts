#!/bin/bash

# 🔴 Paste your Google Gemini API key here
GEMINI_API_KEY="AIzaSyAXKBu8v5ac_ARh-cVvmEEj-JF1Jllod1Y"

# Log files to analyze
LOG_FILES=("/var/log/syslog" "/var/log/messages" "/var/log/auth.log")

# Temporary file for extracted log data
TEMP_LOG_FILE="/tmp/filtered_logs.txt"

# Email or Slack webhook for alerts
ALERT_EMAIL="chetansen2004@gmail.com"
SLACK_WEBHOOK="https://hooks.slack.com/services/YOUR/WEBHOOK"

# Extract relevant log lines
echo "[INFO] Extracting logs..." > "$TEMP_LOG_FILE"
for file in "${LOG_FILES[@]}"; do
    if [[ -f "$file" ]]; then
        echo "[LOG: $file]" >> "$TEMP_LOG_FILE"
        grep -E "error|failed|critical|warning" "$file" | tail -n 100 >> "$TEMP_LOG_FILE"
    fi
done

# Read extracted logs
LOG_CONTENT=$(cat "$TEMP_LOG_FILE")

# Check if log content exists
if [[ -z "$LOG_CONTENT" ]]; then
    echo "[INFO] No significant logs found."
    exit 0
fi

# Send logs to Google Gemini API for analysis
echo "[INFO] Sending logs to Google Gemini AI for analysis..."
RESPONSE=$(curl -s -X POST "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$GEMINI_API_KEY" \
    -H "Content-Type: application/json" \
    -d '{
        "contents": [{"parts": [{"text": "'"$LOG_CONTENT"'"}]}]
    }')

# Extract AI insights
AI_INSIGHT=$(echo "$RESPONSE" | jq -r '.candidates[0].content.parts[0].text')

# Save insights
echo "[AI ANALYSIS]" > "/tmp/log_ai_analysis.txt"
echo "$AI_INSIGHT" >> "/tmp/log_ai_analysis.txt"

# Send alert via email or Slack if critical errors are found
if echo "$AI_INSIGHT" | grep -iq "critical\|urgent"; then
    echo "[ALERT] Critical issues detected!"
    
    # Send email
    echo "Critical log issue detected: $AI_INSIGHT" | mail -s "Log Alert" "$ALERT_EMAIL"

    # Send Slack alert
    curl -X POST -H 'Content-type: application/json' --data "{\"text\":\"Critical Log Issue Detected: $AI_INSIGHT\"}" "$SLACK_WEBHOOK"
fi

echo "[INFO] Log analysis completed. Check /tmp/log_ai_analysis.txt for insights."

