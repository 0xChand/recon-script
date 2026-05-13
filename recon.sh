#!/bin/bash

#  AutoRecon - Automated Reconnaissance Script
#  Author : Chand Raj
#  Usage  : chmod +x recon.sh && ./recon.sh <target>


RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

if [ -z "$1" ]; then
  echo -e "${RED}[!] Usage: $0 <domain or IP>${NC}"
  exit 1
fi

TARGET="$1"
REPORT="recon_${TARGET}_$(date +%Y%m%d_%H%M%S).txt"

echo -e "${CYAN}${BOLD}"
echo "  =======================================  "
echo "   AutoRecon - by Chand Raj               "
echo "   Target : $TARGET                       "
echo "   $(date)                                "
echo "  =======================================  "
echo -e "${NC}"

log() { echo -e "$1" | tee -a "$REPORT"; }

# 1. WHOIS
log "${YELLOW}${BOLD}[ 1. WHOIS LOOKUP ]${NC}"
if command -v whois &>/dev/null; then
  whois "$TARGET" 2>/dev/null \
    | grep -Ei "Registrar:|Creation Date|Expiry Date|Name Server|Status:" \
    | head -10 \
    | while read -r line; do log "  ${GREEN}[+]${NC} $line"; done
else
  log "  ${RED}[!] whois not installed${NC}"
fi

echo "" | tee -a "$REPORT"

# 2. DNS
log "${YELLOW}${BOLD}[ 2. DNS ENUMERATION ]${NC}"
if command -v dig &>/dev/null; then
  for TYPE in A MX NS TXT; do
    RESULT=$(dig +short "$TYPE" "$TARGET" 2>/dev/null)
    if [ -n "$RESULT" ]; then
      log "  ${GREEN}[+]${NC} $TYPE -> $RESULT"
    else
      log "  ${RED}[-]${NC} No $TYPE record"
    fi
  done
else
  log "  ${RED}[!] dig not installed${NC}"
fi

echo "" | tee -a "$REPORT"

# 3. Nmap Port Scan
log "${YELLOW}${BOLD}[ 3. PORT SCAN (NMAP) ]${NC}"
if command -v nmap &>/dev/null; then
  log "  ${CYAN}[*]${NC} Scanning top 100 ports on $TARGET..."
  nmap -sV --open -T4 --top-ports 100 "$TARGET" 2>/dev/null \
    | grep -E "open" \
    | while read -r line; do log "  ${GREEN}[+]${NC} $line"; done
else
  log "  ${RED}[!] nmap not installed${NC}"
fi

echo "" | tee -a "$REPORT"

# 4. SSL Certificate Info
log "${YELLOW}${BOLD}[ 4. SSL CERTIFICATE ]${NC}"
if command -v openssl &>/dev/null; then
  echo "" | openssl s_client -servername "$TARGET" -connect "$TARGET:443" 2>/dev/null \
    | openssl x509 -noout -text 2>/dev/null \
    | grep -E "Subject:|Issuer:|Not Before|Not After" \
    | while read -r line; do log "  ${GREEN}[+]${NC} $line"; done
  if [ $? -ne 0 ]; then
    log "  ${RED}[-]${NC} No SSL certificate or not reachable on 443"
  fi
else
  log "  ${RED}[!] openssl not installed${NC}"
fi

echo "" | tee -a "$REPORT"

# 5. HTTP Headers
log "${YELLOW}${BOLD}[ 5. HTTP HEADERS ]${NC}"
if command -v curl &>/dev/null; then
  curl -sI "http://$TARGET" 2>/dev/null | head -10 | while read -r line; do
    if [ -n "$line" ]; then
      log "  ${GREEN}[+]${NC} $line"
    fi
  done
  if [ $? -ne 0 ]; then
    log "  ${RED}[-]${NC} HTTP not reachable"
  fi
else
  log "  ${RED}[!] curl not installed${NC}"
fi

echo "" | tee -a "$REPORT"

# 6. Reverse DNS Lookup
log "${YELLOW}${BOLD}[ 6. REVERSE DNS LOOKUP ]${NC}"
if command -v dig &>/dev/null; then
  RDNS=$(dig +short -x "$TARGET" 2>/dev/null)
  if [ -n "$RDNS" ]; then
    log "  ${GREEN}[+]${NC} $RDNS"
  else
    log "  ${RED}[-]${NC} No reverse DNS record"
  fi
else
  log "  ${RED}[!] dig not installed${NC}"
fi

echo "" | tee -a "$REPORT"
log "${GREEN}${BOLD}[✓] Done. Report saved to: $REPORT${NC}"