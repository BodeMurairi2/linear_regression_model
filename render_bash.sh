#!/bin/env bash

timestamp=$(date "+%Y-%m-%d %H:%M:%S")
status=$(curl -s -o /dev/null -w "%{http_code}" --max-time 30 https://malaria-prevalence.onrender.com/health)
echo "$timestamp - HTTP $status"
