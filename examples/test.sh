#!/usr/bin/env sh
# Send test payloads for all three formats. Usage: ./test.sh http://HOME_ASSISTANT:8123 YOUR_WEBHOOK_ID
set -eu
URL="$1/api/webhook/$2"

# 1) Alertmanager-style alert (firing)
curl -fsS -X POST "$URL" -H 'Content-Type: application/json' -d '{
  "status": "firing",
  "alerts": [{"status": "firing",
    "labels": {"alertname": "TestAlert", "instance": "test:9100", "severity": "critical"},
    "annotations": {"summary": "Test alert", "description": "If you see this, Alertmanager -> HA works."}}]
}'

# 2) Proxmox-style notification
curl -fsS -X POST "$URL" -H 'Content-Type: application/json' -d '{
  "source": "proxmox", "severity": "error", "title": "Backup job failed", "message": "vzdump 100: test message"
}'

# 3) Diun-style update
curl -fsS -X POST "$URL" -H 'Content-Type: application/json' -d '{
  "diun_version": "4.28.0", "hostname": "docker", "status": "update",
  "image": "docker.io/library/nginx:latest", "hub_link": "https://hub.docker.com/_/nginx"
}'

echo "Sent 3 test notifications."
# Or, with amtool:
# amtool alert add TestAlert severity=warning instance=test --annotation=summary="Test via amtool" --alertmanager.url=http://ALERTMANAGER:9093
