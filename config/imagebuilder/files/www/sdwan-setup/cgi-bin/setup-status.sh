#!/bin/sh
# SoftAP 初始化状态 JSON。不打印 PSK / token / secret。
printf 'Content-Type: application/json\r\nCache-Control: no-store\r\n\r\n'

SSID=""
[ -f /etc/jinwei/setup-ssid ] && SSID=$(tr -d '\n\r' < /etc/jinwei/setup-ssid)

MAC=""
for n in eth0 eth1 br-lan; do
  [ -r "/sys/class/net/$n/address" ] || continue
  MAC=$(cat "/sys/class/net/$n/address" | tr -d '\n')
  [ -n "$MAC" ] && break
done

MODEL="unknown"
[ -f /tmp/sysinfo/model ] && MODEL=$(cat /tmp/sysinfo/model | tr -d '\n' | sed 's/"/\\"/g')

LAN=""
LAN=$(ip -4 addr show br-lan 2>/dev/null | awk '/inet / {print $2; exit}' | cut -d/ -f1)
[ -z "$LAN" ] && LAN=$(ip -4 route get 1.1.1.1 2>/dev/null | awk '{for(i=1;i<=NF;i++) if($i=="src"){print $(i+1); exit}}')

DEVICE_ID=""
if [ -f /etc/sdwan-agent/state ]; then
  DEVICE_ID=$(grep -E '^DEVICE_ID=' /etc/sdwan-agent/state 2>/dev/null | head -n1 | cut -d= -f2- | tr -d "'\"")
fi
SHORT=""
[ -n "$DEVICE_ID" ] && SHORT=$(printf '%s' "$DEVICE_ID" | cut -c1-12)

ET="absent"
command -v easytier-cli >/dev/null 2>&1 && ET="installed"
if pgrep -x easytier-core >/dev/null 2>&1 || pgrep easytier-core >/dev/null 2>&1; then
  ET="running"
fi

MGMT_URL="https://sdwan.higmcn.com"
[ -f /etc/sdwan-agent/config ] && . /etc/sdwan-agent/config 2>/dev/null || true
[ -f /etc/sdwan-ui/ui.conf ] && . /etc/sdwan-ui/ui.conf 2>/dev/null || true

CLOUD="false"
check_cloud() {
  _url="$1"
  _code=$(curl -sS -m 5 -o /dev/null -w '%{http_code}' "$_url" 2>/dev/null || echo 000)
  case "$_code" in
    200|204|301|302) return 0 ;;
  esac
  _host=$(printf '%s' "$_url" | sed -n 's|https://\([^/]*\).*|\1|p')
  [ -n "$_host" ] || return 1
  _ip=$(nslookup "$_host" 10.0.0.1 2>/dev/null | awk '/^Address: /{a=$2} END{print a}')
  [ -n "$_ip" ] || _ip=$(nslookup "$_host" 223.5.5.5 2>/dev/null | awk '/^Address: /{a=$2} END{print a}')
  [ -n "$_ip" ] || return 1
  _code=$(curl -sS -m 5 -o /dev/null -w '%{http_code}' --resolve "${_host}:443:${_ip}" "$_url" 2>/dev/null || echo 000)
  case "$_code" in
    200|204|301|302) return 0 ;;
  esac
  return 1
}
if check_cloud "${MGMT_URL}/v1/health" || check_cloud "${MGMT_URL}/health"; then
  CLOUD="true"
fi

ENROLLED="false"
[ -n "$DEVICE_ID" ] && ENROLLED="true"

SSID_ESC=$(printf '%s' "$SSID" | sed 's/\\/\\\\/g; s/"/\\"/g')
MAC_ESC=$(printf '%s' "$MAC" | sed 's/"/\\"/g')

printf '{"ssid":"%s","mac":"%s","model":"%s","lan_ip":"%s","cloud_reachable":%s,"device_enrolled":%s,"device_id_short":"%s","easytier":"%s","setup_gw":"192.168.88.1"}\n' \
  "$SSID_ESC" "$MAC_ESC" "$MODEL" "${LAN:-}" "$CLOUD" "$ENROLLED" "$SHORT" "$ET"
