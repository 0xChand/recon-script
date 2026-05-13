# AutoRecon

Quick reconnaissance script for domain/IP reconnaissance. Gathers whois, DNS, SSL, HTTP headers, port info, and reverse DNS data in one shot.

## Usage

```bash
chmod +x recon.sh
./recon.sh example.com
```

## What it checks

- **WHOIS** — Registrar, dates, name servers
- **DNS** — A, MX, NS, TXT records
- **Ports** — Top 100 ports via nmap
- **SSL** — Certificate details
- **HTTP** — Response headers
- **Reverse DNS** — Hostname from IP

## Requirements

- `whois` — Domain registration info
- `dig` — DNS queries
- `nmap` — Port scanning
- `openssl` — SSL certificate inspection
- `curl` — HTTP headers

All tools are optional; the script skips what's not installed.

## Output

Results saved to `recon_[target]_[timestamp].txt`