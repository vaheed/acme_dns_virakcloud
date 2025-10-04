# Virak Cloud DNS API Implementation Guide for acme.sh

## Overview
This guide will help you create a DNS API plugin for Virak Cloud to work with acme.sh for automatic SSL certificate issuance using DNS-01 challenge.

## Step-by-Step Implementation

### 1. Understand the Virak Cloud API

First, you need to examine the Virak Cloud DNS API documentation at https://api-docs.virakcloud.com/#tag/dns and identify:

- **API Base URL**: Usually something like `https://public-api.virakcloud.com`
- **Authentication method**: Bearer token, API key in header, Basic Auth, etc.
- **DNS Zone endpoints**:
  - List zones: `GET /zones` or similar
  - List records: `GET /zones/{zone_id}/records`
  - Create record: `POST /zones/{zone_id}/records`
  - Delete record: `DELETE /zones/{zone_id}/records/{record_id}`
- **Request/Response format**: JSON, XML, or form-encoded
- **Required headers**: Content-Type, Authorization, etc.

### 2. Customize the Template

The template provided needs to be adjusted based on the actual Virak Cloud API. Key areas to modify:

#### API URL and Authentication
```bash
VIRAKCLOUD_API="https://public-api.virakcloud.com"  # Adjust based on docs

# In _virakcloud_rest function, adjust headers:
export _H1="Authorization: Bearer $VIRAKCLOUD_API_KEY"
# Or if using different auth:
# export _H1="X-API-Key: $VIRAKCLOUD_API_KEY"
```

#### JSON Payload Format
Adjust the record creation payload to match Virak Cloud's format:
```bash
# Example formats you might encounter:
# Format 1:
_record_data="{\"name\":\"$_sub_domain\",\"type\":\"TXT\",\"content\":\"$txtvalue\",\"ttl\":120}"

# Format 2:
_record_data="{\"records\":[{\"name\":\"$_sub_domain\",\"type\":\"TXT\",\"value\":\"$txtvalue\"}]}"

# Format 3:
_record_data="{\"hostname\":\"$_sub_domain\",\"record_type\":\"TXT\",\"data\":\"$txtvalue\"}"
```

#### Response Parsing
Update the response parsing based on the actual API response format:
```bash
# Example: If API returns {"data":{"records":[{"id":"123",...}]}}
_record_id=$(echo "$response" | _egrep_o '"id":"[^"]*"' | cut -d'"' -f4)

# Or if it returns {"records":[{"record_id":123,...}]}
_record_id=$(echo "$response" | _egrep_o '"record_id":[0-9]+' | _egrep_o '[0-9]+')
```

### 3. File Naming and Placement

**File name**: `dns_virakcloud.sh`

**For testing** (local use):
- Place in: `~/.acme.sh/dnsapi/dns_virakcloud.sh`
- Or: `~/.acme.sh/dns_virakcloud.sh`

**For contributing** to acme.sh:
- Place in: `acme.sh/dnsapi/dns_virakcloud.sh`

### 4. Testing Your Implementation

#### Enable Debug Mode
Always test with debug mode and staging:
```bash
# Test with debug output
acme.sh --issue --staging --debug 2 -d example.com --dns dns_virakcloud

# If domain was validated before, deactivate first
acme.sh --deactivate -d example.com
```

#### Testing Checklist
1. ✅ Test adding TXT record
2. ✅ Test removing TXT record
3. ✅ Test with single domain
4. ✅ Test with wildcard domain (*.example.com)
5. ✅ Test with multiple subdomains
6. ✅ Test credential saving and reuse
7. ✅ Verify records are actually created in DNS

### 5. Handle Edge Cases

#### Wildcard Certificates
Wildcard certs require TWO TXT records with the same name. Ensure your add function appends rather than replaces:
```bash
# Good: Append new record
_virakcloud_rest POST "zones/$_domain/records" "$_record_data"

# Bad: Update existing record (will fail for wildcards)
```

#### Multiple DNS Records
After adding, verify with:
```bash
dig -t txt _acme-challenge.example.com

# Should show multiple records for wildcards:
# _acme-challenge.example.com. 120 IN TXT "value1"
# _acme-challenge.example.com. 120 IN TXT "value2"
```

#### Root Zone Detection
The `_get_root()` function must handle:
- `example.com`
- `example.co.uk`
- `_acme-challenge.www.example.com`
- `_acme-challenge.sub1.sub2.example.co.uk`

### 6. Code Quality Requirements

#### Don't Use
- ❌ `curl` or `wget` directly (use `_get` and `_post` instead)
- ❌ `awk` (use `sed`, `grep`, `cut`, `paste` instead)
- ❌ Hardcoded domain assumptions

#### Do Use
- ✅ `_get()` and `_post()` for HTTP requests
- ✅ `_debug()`, `_info()`, `_err()` for logging
- ✅ `_saveaccountconf_mutable()` for credentials
- ✅ `_contains()`, `_startswith()`, `_endswith()` for string operations
- ✅ `_egrep_o()` for pattern matching

### 7. Contributing to acme.sh

#### Create an Issue
1. Create a new issue on GitHub: https://github.com/acmesh-official/acme.sh/issues
2. Title: "Report bugs to Virak Cloud DNS API"
3. Keep this issue open for future bug reports

#### Update Documentation
Add your DNS provider to: https://github.com/acmesh-official/acme.sh/wiki/dnsapi2

```markdown
<a name="dns_virakcloud"/>

## Use Virak Cloud DNS API

Get your API key from Virak Cloud dashboard.

```bash
export VIRAKCLOUD_API_KEY="your-api-key-here"
acme.sh --issue --dns dns_virakcloud -d example.com -d *.example.com
```

The `VIRAKCLOUD_API_KEY` will be saved in `~/.acme.sh/account.conf` and will be reused when needed.

Report any bugs or issues here: https://github.com/acmesh-official/acme.sh/issues/XXXX
```

#### Submit Pull Request
1. Fork the acme.sh repository
2. Create a new branch: `git checkout -b add-virakcloud-dns`
3. Add your file to `dnsapi/dns_virakcloud.sh`
4. Commit: `git commit -m "Add Virak Cloud DNS API support"`
5. Push and create pull request

### 8. Usage Example

Once implemented, users will use it like this:

```bash
# Set API credentials
export VIRAKCLOUD_API_KEY="your-api-key-here"

# Issue certificate
acme.sh --issue --dns dns_virakcloud -d example.com -d www.example.com

# Issue wildcard certificate
acme.sh --issue --dns dns_virakcloud -d example.com -d *.example.com

# The credentials are saved and will be reused for renewals
```

## Common API Patterns

### Pattern 1: RESTful with Bearer Token
```bash
export _H1="Authorization: Bearer $VIRAKCLOUD_API_KEY"
export _H2="Content-Type: application/json"
```

### Pattern 2: API Key in Header
```bash
export _H1="X-API-Key: $VIRAKCLOUD_API_KEY"
export _H2="Content-Type: application/json"
```

### Pattern 3: Basic Authentication
```bash
mycredentials="$(printf "%s" "$username:$password" | _base64)"
export _H1="Authorization: Basic $mycredentials"
```

## Debugging Tips

1. **Check API calls**: Use `--debug 2` to see all API requests and responses
2. **Verify DNS propagation**: Use `dig` or online DNS checkers
3. **Check timing**: Some DNS providers need time to propagate (30-120 seconds)
4. **Test incrementally**: Test each function separately
5. **Read existing implementations**: Look at similar providers in `dnsapi/` folder

## References

- DNS API Dev Guide: https://github.com/acmesh-official/acme.sh/wiki/DNS-API-Dev-Guide
- DNS API Test Guide: https://github.com/acmesh-official/acme.sh/wiki/DNS-API-Test
- Code of Conduct: https://github.com/acmesh-official/acme.sh/wiki/Code-of-conduct
- Existing implementations: https://github.com/acmesh-official/acme.sh/tree/master/dnsapi
