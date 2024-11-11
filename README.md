# Dovecot image

Dockerized dovecot MDA agent for x86_64/arm64

### ENV
- `DOVECOT_CONFIG` - path to custom dovecot config location
  process it through `gomplate` and write to `/etc/dovecot/local.conf`

Example config
```
protocols = pop3 imap lmtp
auth_mechanisms = plain login
mail_location = maildir:/var/mail/vmail/%d/%u/
log_path = /dev/stdout

mbox_write_locks = fcntl
disable_plaintext_auth = yes

service imap-login {
  inet_listener imap {
    port=0
  }
  inet_listener imaps {
    port = 993
    ssl = yes
  }
}

service pop3-login {
  inet_listener pop3 {
    port=0
  }
  inet_listener pop3s {
    port = 995
    ssl = yes
  }
}

service auth {
  inet_listener {
    port = 44111
    address = 127.0.0.1
  }
}

service lmtp {
  inet_listener {
    port = 55111
    address = 127.0.0.1
  }
#  unix_listener /var/spool/postfix/private/dovecot-lmtp {
#    mode = 0600
#    user = postfix
#    group = postfix
#  }
}

# статистика
service stats {
  inet_listener {
    address = 127.0.0.1
    port = 24242
  }
}

protocol lmtp {
  postmaster_address = postmaster@domain
}

# ssl config
ssl = required
ssl_cert = </etc/certs/tls.crt
ssl_key = </etc/certs/tls.key


# folder auto creation
lda_mailbox_autocreate = yes

# enable sql auth
!include conf.d/auth-sql.conf.ext

# bind all interfaces
listen = *

```