# Self-Hosted Strapi CMS

Strapi CMS with Caddy (auto SSL), SQLite, and SendGrid email.

## Deploy to VPS

```bash
git clone https://github.com/YOUR_USER/cms-project.git
cd cms-project
nano .env
chmod +x cms.sh
./cms.sh start
```

## Data Persistence

All persistent data is stored in `./data/`:
```
data/
├── caddy/
│   ├── data/      # SSL certificates
│   └── config/    # Caddy config cache
└── strapi-content/
    ├── tmp/       # SQLite database (data.db)
    └── uploads/   # Media uploads
```

This directory persists across container restarts/updates.

## Configuration (.env)

```bash
DOMAIN=cms.yourdomain.com
PUBLIC_URL=https://cms.yourdomain.com
ACME_EMAIL=admin@yourdomain.com

# Generate with: openssl rand -base64 32
APP_KEYS=key1,key2,key3,key4
API_TOKEN_SALT=...
ADMIN_JWT_SECRET=...
TRANSFER_TOKEN_SALT=...
JWT_SECRET=...

# SendGrid
SENDGRID_API_KEY=SG.xxx
SMTP_FROM_EMAIL=noreply@yourdomain.com
SMTP_REPLY_TO_EMAIL=support@yourdomain.com
```

## Commands

```bash
./cms.sh start      # Start (creates data dirs automatically)
./cms.sh stop       # Stop
./cms.sh restart    # Restart
./cms.sh status     # Status + data usage
./cms.sh logs -f    # Follow logs
./cms.sh health     # Health + data status
./cms.sh backup     # Backup entire data directory
./cms.sh update     # Pull latest & restart
```

## Backup/Restore

```bash
# Backup (creates backups/strapi_YYYYMMDD_full.tar.gz)
./cms.sh backup

# Restore
./cms.sh stop
tar xzf backups/strapi_YYYYMMDD_full.tar.gz
./cms.sh start
```
