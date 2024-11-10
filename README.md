# Dovecot image

Dockerized dovecot MDA agent for x86_64/arm64

### ENV
- `DOVECOT_CONFIG` - path to custom dovecot config location
  process it through `gomplate` and write to `/etc/dovecot/local.conf`