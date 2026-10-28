#!/bin/sh
# Device-local status JSON. NEVER print tokens / secrets / passwords.
printf 'Content-Type: application/json\r\nCache-Control: no-store\r\n\r\n'

FACTORY_NAME="工厂-未命名"
MGMT_URL="https://sdwan.higmcn.com"
MONITOR_URL=""
DEVICE_ID=""
# ui.conf may set FACTORY_NAME / MGMT_URL / MONITOR_URL only
if [ -f /etc/sdwan-ui/ui.conf ]; then
  # shellcheck disable=SC1091
  . /etc/sdwan-ui/ui.conf
fi

# enrolled? only DEVICE_ID from state — strip DEVICE_TOKEN lines
if [ -f /etc/sdwan-agent/state ]; then
  DEVICE_ID=$(grep -E '^DEVICE_ID=' /etc/sdwan-agent/state 2>/dev/null | head -n1 | cut -d= -f2- | tr -d "'\"")
fi
SHORT=""
if [ -n "$DEVICE_ID" ]; then
  SHORT=$(printf '%s' "$DEVICE_ID" | cut -c1-12)
fi

LAN=""
LAN=$(ip -4 addr show br-lan 2>/dev/null | awk '/inet / {print $2; exit}' | cut -d/ -f1)
[ -z "$LAN" ] && LAN=$(ip -4 route get 1.1.1.1 2>/dev/null | awk '{for(i=1;i<=NF;i++) if($i=="src"){print $(i+1); exit}}')

MODEL="unknown"
[ -f /tmp/sysinfo/model ] && MODEL=$(cat /tmp/sysinfo/model | tr -d '\n' | sed 's/"/\\"/g')

ET="absent"
command -v easytier-cli >/dev/null 2>&1 && ET="installed"
if pgrep -x easytier-core >/dev/null 2>&1 || pgrep easytier-core >/dev/null 2>&1; then
  ET="running"
fi

CLOUD="false"
# only hit public health — no auth headers, no tokens
code=$(curl -sS -m 5 -o /dev/null -w '%{http_code}' "${MGMT_URL}/health" 2>/dev/null || echo 000)
[ "$code" = "200" ] && CLOUD="true"

ENROLLED="false"
[ -n "$DEVICE_ID" ] && ENROLLED="true"

# JSON escape factory name
FN=$(printf '%s' "$FACTORY_NAME" | sed 's/\\/\\\\/g; s/"/\\"/g')
MU=$(printf '%s' "$MGMT_URL" | sed 's/"/\\"/g')
MON=$(printf '%s' "$MONITOR_URL" | sed 's/"/\\"/g')

printf '{"factory_name":"%s","lan_ip":"%s","model":"%s","cloud_reachable":%s,"device_enrolled":%s,"device_id_short":"%s","easytier":"%s","mgmt_url":"%s","monitor_url":"%s"}\n' \
  "$FN" "${LAN:-}" "$MODEL" "$CLOUD" "$ENROLLED" "$SHORT" "$ET" "$MU" "$MON"
