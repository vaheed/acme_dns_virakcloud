# DNS Provider Integration - Repository Addresses

Here are the main projects that support custom DNS providers for SSL certificate management:

---

## 1. **acme.sh** (Shell Script - Most DNS Providers)

**Main Repository:**
- https://github.com/acmesh-official/acme.sh

**DNS API Folder:**
- https://github.com/acmesh-official/acme.sh/tree/master/dnsapi

**Documentation:**
- Dev Guide: https://github.com/acmesh-official/acme.sh/wiki/DNS-API-Dev-Guide
- DNS API List: https://github.com/acmesh-official/acme.sh/wiki/dnsapi
- Test Guide: https://github.com/acmesh-official/acme.sh/wiki/DNS-API-Test

**Language:** Shell Script
**Providers Supported:** 150+ DNS providers
**Template File:** `dns_myapi.sh`

---

## 2. **Nginx Proxy Manager** (Uses Certbot)

**Main Repository:**
- https://github.com/NginxProxyManager/nginx-proxy-manager

**DNS Plugins Configuration:**
- https://github.com/NginxProxyManager/nginx-proxy-manager/blob/develop/global/certbot-dns-plugins.json

**Base:** Uses Certbot plugins underneath
**Language:** JavaScript/Docker
**Add Provider By:** Creating Certbot plugin or adding to their JSON config

**Related Issue:**
- https://github.com/NginxProxyManager/nginx-proxy-manager/issues/836

---

## 3. **Certbot** (Official Let's Encrypt Client)

**Main Repository:**
- https://github.com/certbot/certbot

**DNS Plugins Folder:**
- https://github.com/certbot/certbot/tree/master/certbot-dns-cloudflare
- https://github.com/certbot/certbot/tree/master/certbot-dns-route53
- (Each provider has its own plugin package)

**Documentation:**
- https://eff-certbot.readthedocs.io/en/stable/using.html#dns-plugins
- Plugin Development: https://certbot.eff.org/docs/contributing.html

**Language:** Python
**How to Add:** Create a Python package following the plugin interface

**Plugin Format:** `certbot-dns-{provider}`

---

## 4. **Caddy Server** (Go-based Web Server)

**Main Repository:**
- https://github.com/caddyserver/caddy

**DNS Provider Organization:**
- https://github.com/caddy-dns (All DNS provider modules)

**Individual Provider Repositories:**
- Cloudflare: https://github.com/caddy-dns/cloudflare
- Route53: https://github.com/caddy-dns/route53
- DigitalOcean: https://github.com/caddy-dns/digitalocean
- DuckDNS: https://github.com/caddy-dns/duckdns
- Namecheap: https://github.com/caddy-dns/namecheap
- Gandi: https://github.com/caddy-dns/gandi
- Vultr: https://github.com/caddy-dns/vultr
- And 80+ more...

**Documentation:**
- DNS Challenge Guide: https://caddy.community/t/how-to-use-dns-provider-modules-in-caddy-2/8148
- Module List: https://caddyserver.com/docs/modules/
- Building Plugins: https://caddyserver.com/docs/extending-caddy

**Language:** Go
**Base Library:** Uses libdns (https://github.com/libdns)

**Template Repository:** 
- https://github.com/caddy-dns/template

---

## 5. **LEGO** (Go ACME Client Library)

**Main Repository:**
- https://github.com/go-acme/lego

**DNS Providers Folder:**
- https://github.com/go-acme/lego/tree/master/providers/dns

**Documentation:**
- https://go-acme.github.io/lego/dns/
- Provider List: https://go-acme.github.io/lego/dns/

**Language:** Go
**Providers Supported:** 100+ DNS providers
**Used By:** Many projects use LEGO as a library

**How to Add:**
- Contributing Guide: https://go-acme.github.io/lego/contributing/dns/

---

## 6. **Traefik** (Uses LEGO)

**Main Repository:**
- https://github.com/traefik/traefik

**Documentation:**
- Let's Encrypt: https://doc.traefik.io/traefik/https/acme/
- DNS Challenge: https://doc.traefik.io/traefik/https/acme/#dnschallenge

**Note:** Traefik uses LEGO library, so it supports all LEGO DNS providers automatically.

---

## 7. **libdns** (Go DNS Library - Used by Caddy)

**Main Organization:**
- https://github.com/libdns

**Individual Provider Repositories:**
- Cloudflare: https://github.com/libdns/cloudflare
- Route53: https://github.com/libdns/route53
- DigitalOcean: https://github.com/libdns/digitalocean
- And 100+ more...

**Language:** Go
**Purpose:** Standardized DNS provider interface for Go projects

**Template:**
- https://github.com/libdns/template

---

## 8. **Posh-ACME** (PowerShell ACME Client)

**Main Repository:**
- https://github.com/rmbolger/Posh-ACME

**DNS Plugins Folder:**
- https://github.com/rmbolger/Posh-ACME/tree/main/Posh-ACME/Plugins

**Documentation:**
- https://poshac.me/docs/v4/Plugins/
- Creating Plugins: https://poshac.me/docs/v4/Plugins/Plugin-Dev-Guide/

**Language:** PowerShell
**Providers Supported:** 50+ DNS providers

---

## 9. **Dehydrated** (Shell Script ACME Client)

**Main Repository:**
- https://github.com/dehydrated-io/dehydrated

**DNS Hooks:**
- https://github.com/dehydrated-io/dehydrated/wiki/Examples-for-DNS-01-hooks

**Language:** Shell Script
**Note:** Uses hook scripts for DNS providers

---

## 10. **acme-dns-route53** and Similar Single-Provider Projects

Many single-purpose implementations exist:
- https://github.com/begmaroman/acme-dns-route53
- https://github.com/nrdcg/desec
- Various provider-specific implementations

---

## Comparison Table

| Project | Language | DNS Providers | Difficulty | Best For |
|---------|----------|---------------|------------|----------|
| acme.sh | Shell | 150+ | Easy | Universal, quick integration |
| Nginx Proxy Manager | JS/Python | 40+ (Certbot) | Medium | GUI management |
| Certbot | Python | 15+ official | Medium | Python developers |
| Caddy | Go | 100+ | Medium | Modern web server |
| LEGO | Go | 100+ | Medium | Go applications |
| Traefik | Go | 100+ (LEGO) | Easy | Container orchestration |
| Posh-ACME | PowerShell | 50+ | Easy | Windows environments |

---

## Recommended Approach for Virak Cloud

Based on your needs, here's the priority order:

### 1. **acme.sh** (Highest Priority)
- ✅ Easiest to implement (Shell script)
- ✅ Most widely used
- ✅ Quick to test
- ✅ Large community
- **Repository:** https://github.com/acmesh-official/acme.sh/tree/master/dnsapi

### 2. **LEGO** (High Priority)
- ✅ Second most popular
- ✅ Used by Traefik
- ✅ Good if you know Go
- **Repository:** https://github.com/go-acme/lego/tree/master/providers/dns

### 3. **libdns** (Medium Priority)
- ✅ Powers Caddy
- ✅ Clean Go interface
- ✅ Growing ecosystem
- **Repository:** https://github.com/libdns

### 4. **Certbot** (Medium Priority)
- ✅ Official Let's Encrypt client
- ✅ Powers Nginx Proxy Manager
- ✅ Good if you know Python
- **Repository:** https://github.com/certbot/certbot

---

## Getting Started

1. **Start with acme.sh** - It's the easiest and will give you the most reach
2. **Then add LEGO support** - This gives you Traefik support
3. **Consider libdns** - This adds Caddy support
4. **Finally Certbot** - This enables Nginx Proxy Manager

Most users will find your provider through acme.sh, so that should be your first target!

---

## Additional Resources

### General ACME Information
- ACME Protocol Spec: https://tools.ietf.org/html/rfc8555
- Let's Encrypt Docs: https://letsencrypt.org/docs/

### Testing
- Let's Encrypt Staging: https://letsencrypt.org/docs/staging-environment/
- Pebble (Local ACME Server): https://github.com/letsencrypt/pebble

### DNS Validation
- DNS-01 Challenge Spec: https://letsencrypt.org/docs/challenge-types/#dns-01-challenge
