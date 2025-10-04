#!/usr/bin/env sh

# Virak Cloud DNS API
# https://api-docs.virakcloud.com/#tag/dns
#
# Author: Your Name
# Report Bugs here: https://github.com/acmesh-official/acme.sh/issues/XXXX
#
# Usage:
# export VIRAKCLOUD_API_KEY="your-api-key-here"
# acme.sh --issue --dns dns_virakcloud -d example.com -d *.example.com

# DNS API Info (for automatic generation of API list)
# VirakCloud_API="https://public-api.virakcloud.com"
# VIRAKCLOUD_API_KEY - Required - Your API Key

VIRAKCLOUD_API="https://public-api.virakcloud.com"

######## Public functions ###########

# Usage: add _acme-challenge.www.domain.com "XKrxpRBosdIKFzxW_CT3KLZNf6q0HG9i01zxXp5CPBs"
# Used to add txt record
dns_virakcloud_add() {
  fulldomain=$1
  txtvalue=$2
  
  _info "Using Virak Cloud DNS API"
  _debug fulldomain "$fulldomain"
  _debug txtvalue "$txtvalue"
  
  # Load credentials
  VIRAKCLOUD_API_KEY="${VIRAKCLOUD_API_KEY:-$(_readaccountconf_mutable VIRAKCLOUD_API_KEY)}"
  
  if [ -z "$VIRAKCLOUD_API_KEY" ]; then
    VIRAKCLOUD_API_KEY=""
    _err "You didn't specify Virak Cloud API key yet."
    _err "Please set VIRAKCLOUD_API_KEY and try again."
    return 1
  fi
  
  # Save the credentials to account conf file
  _saveaccountconf_mutable VIRAKCLOUD_API_KEY "$VIRAKCLOUD_API_KEY"
  
  _debug "Detecting root zone"
  if ! _get_root "$fulldomain"; then
    _err "Invalid domain: $fulldomain"
    return 1
  fi
  
  _debug _domain "$_domain"
  _debug _sub_domain "$_sub_domain"
  
  # Check if TXT record already exists (for wildcard certs)
  _info "Checking existing records"
  if ! _virakcloud_rest GET "zones/$_domain/records?name=$_sub_domain&type=TXT"; then
    _err "Error checking existing records"
    return 1
  fi
  
  # Add the TXT record
  _info "Adding TXT record"
  
  # Construct JSON payload - adjust based on actual Virak Cloud API requirements
  _record_data="{\"name\":\"$_sub_domain\",\"type\":\"TXT\",\"content\":\"$txtvalue\",\"ttl\":120}"
  
  if ! _virakcloud_rest POST "zones/$_domain/records" "$_record_data"; then
    _err "Error adding TXT record"
    return 1
  fi
  
  _info "TXT record added successfully"
  return 0
}

# Usage: fulldomain txtvalue
# Used to remove the txt record after validation
dns_virakcloud_rm() {
  fulldomain=$1
  txtvalue=$2
  
  _info "Using Virak Cloud DNS API"
  _debug fulldomain "$fulldomain"
  _debug txtvalue "$txtvalue"
  
  # Load credentials
  VIRAKCLOUD_API_KEY="${VIRAKCLOUD_API_KEY:-$(_readaccountconf_mutable VIRAKCLOUD_API_KEY)}"
  
  if [ -z "$VIRAKCLOUD_API_KEY" ]; then
    VIRAKCLOUD_API_KEY=""
    _err "You didn't specify Virak Cloud API key yet."
    return 1
  fi
  
  _debug "Detecting root zone"
  if ! _get_root "$fulldomain"; then
    _err "Invalid domain: $fulldomain"
    return 1
  fi
  
  _debug _domain "$_domain"
  _debug _sub_domain "$_sub_domain"
  
  # Get record ID
  _info "Finding TXT record to delete"
  if ! _virakcloud_rest GET "zones/$_domain/records?name=$_sub_domain&type=TXT"; then
    _err "Error finding TXT record"
    return 1
  fi
  
  # Parse record ID from response - adjust based on actual API response format
  _record_id=$(echo "$response" | _egrep_o '"id":"[^"]*"' | cut -d'"' -f4 | head -n 1)
  
  if [ -z "$_record_id" ]; then
    _info "TXT record not found, may already be deleted"
    return 0
  fi
  
  _debug _record_id "$_record_id"
  
  # Delete the record
  _info "Deleting TXT record"
  if ! _virakcloud_rest DELETE "zones/$_domain/records/$_record_id"; then
    _err "Error deleting TXT record"
    return 1
  fi
  
  _info "TXT record deleted successfully"
  return 0
}

####################  Private functions below ##################################

# _sub_domain=_acme-challenge.www
# _domain=domain.com
# _domain_id=12345
_get_root() {
  domain=$1
  i=1
  p=1
  
  # Try to get the zone list from API
  if ! _virakcloud_rest GET "zones"; then
    return 1
  fi
  
  # Parse zones from response - adjust based on actual API response format
  # This is a placeholder - you need to adjust based on actual API response
  while true; do
    h=$(printf "%s" "$domain" | cut -d . -f $i-100)
    _debug h "$h"
    
    if [ -z "$h" ]; then
      # Not valid
      return 1
    fi
    
    # Check if this zone exists in the response
    if _contains "$response" "\"name\":\"$h\"" || _contains "$response" "\"domain\":\"$h\""; then
      _sub_domain=$(printf "%s" "$domain" | cut -d . -f 1-$p)
      _domain=$h
      return 0
    fi
    
    p=$i
    i=$(_math "$i" + 1)
  done
  
  return 1
}

# method  uri  data
_virakcloud_rest() {
  method=$1
  uri="$2"
  data="$3"
  
  _debug method "$method"
  _debug uri "$uri"
  
  # Set authorization header - adjust based on actual API requirements
  export _H1="Authorization: Bearer $VIRAKCLOUD_API_KEY"
  export _H2="Content-Type: application/json"
  export _H3="Accept: application/json"
  
  # Construct full URL
  _api_url="$VIRAKCLOUD_API/$uri"
  _debug _api_url "$_api_url"
  
  if [ "$method" != "GET" ]; then
    _debug data "$data"
    response="$(_post "$data" "$_api_url" "" "$method")"
  else
    response="$(_get "$_api_url")"
  fi
  
  _ret="$?"
  _debug response "$response"
  
  if [ "$_ret" != "0" ]; then
    _err "Error: API request failed"
    return 1
  fi
  
  # Check for errors in response - adjust based on actual API error format
  if _contains "$response" '"error"' || _contains "$response" '"errors"'; then
    _err "API Error: $response"
    return 1
  fi
  
  return 0
}
