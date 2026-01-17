#!/usr/bin/env bash
# Strapi CMS Management Script

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'
BOLD='\033[1m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT="strapi-cms"
DATA_DIR="${SCRIPT_DIR}/data"

dc() { docker compose -f "${SCRIPT_DIR}/docker-compose.yml" -p "$PROJECT" "$@"; }

print_ok() { echo -e "${GREEN}✓ $1${NC}"; }
print_err() { echo -e "${RED}✗ $1${NC}"; }
print_warn() { echo -e "${YELLOW}⚠ $1${NC}"; }
print_info() { echo -e "${BLUE}ℹ $1${NC}"; }

check_docker() {
    docker info > /dev/null 2>&1 || { print_err "Docker not running"; exit 1; }
}

check_env() {
    [ -f "${SCRIPT_DIR}/.env" ] || { print_warn ".env not found. Run: cp .env.example .env && nano .env"; exit 1; }
}

generate_key() {
    openssl rand -base64 32
}

fill_security_keys() {
    local env_file="${SCRIPT_DIR}/.env"
    
    print_info "Generating security keys..."
    
    # Generate APP_KEYS (4 comma-separated keys)
    local app_keys="$(generate_key),$(generate_key),$(generate_key),$(generate_key)"
    sed -i "s|^APP_KEYS=.*|APP_KEYS=${app_keys}|" "$env_file"
    
    # Generate individual keys
    sed -i "s|^API_TOKEN_SALT=.*|API_TOKEN_SALT=$(generate_key)|" "$env_file"
    sed -i "s|^ADMIN_JWT_SECRET=.*|ADMIN_JWT_SECRET=$(generate_key)|" "$env_file"
    sed -i "s|^TRANSFER_TOKEN_SALT=.*|TRANSFER_TOKEN_SALT=$(generate_key)|" "$env_file"
    sed -i "s|^JWT_SECRET=.*|JWT_SECRET=$(generate_key)|" "$env_file"
    
    print_ok "Security keys generated and saved to .env"
}

cmd_start() {
    check_env
    fill_security_keys
    
    print_info "Building and starting Strapi CMS..."
    dc up -d --build
    print_ok "Started! First boot takes ~2 min."
    
    source "${SCRIPT_DIR}/.env" 2>/dev/null
    echo -e "\n${BOLD}Access:${NC} https://${DOMAIN:-localhost}/admin\n"
    cmd_status
}

cmd_stop() {
    print_info "Stopping..."
    dc down
    print_ok "Stopped"
}

cmd_restart() {
    dc restart
    print_ok "Restarted"
    cmd_status
}

cmd_status() {
    echo -e "\n${BOLD}Status:${NC}"
    dc ps
    echo ""
    docker stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}" $(dc ps -q 2>/dev/null) 2>/dev/null || true
    
    echo -e "\n${BOLD}Data Directory:${NC}"
    du -sh "${DATA_DIR}"/* 2>/dev/null || echo "No data yet"
}

cmd_logs() {
    local follow=""
    local service=""
    for arg in "$@"; do
        case "$arg" in
            -f) follow="-f" ;;
            strapi|caddy) service="$arg" ;;
        esac
    done
    dc logs $follow --tail=100 $service
}

cmd_health() {
    echo -e "\n${BOLD}Health Check:${NC}"
    for svc in strapi-cms caddy-proxy; do
        status=$(docker inspect --format='{{.State.Status}}' "$svc" 2>/dev/null || echo "not found")
        if [ "$status" = "running" ]; then
            print_ok "$svc: running"
        else
            print_err "$svc: $status"
        fi
    done
    
    echo -e "\n${BOLD}Data Persistence:${NC}"
    [ -d "${DATA_DIR}/caddy/data/caddy" ] && print_ok "Caddy SSL certs: present" || print_warn "Caddy SSL certs: not yet generated"
    [ -f "${DATA_DIR}/strapi-content/tmp/data.db" ] && print_ok "SQLite database: present" || print_warn "SQLite database: not yet created"
}

cmd_backup() {
    local backup_dir="${SCRIPT_DIR}/backups"
    local ts=$(date +"%Y%m%d_%H%M%S")
    mkdir -p "$backup_dir"
    
    print_info "Backing up data directory..."
    tar czf "${backup_dir}/strapi_${ts}_full.tar.gz" -C "${SCRIPT_DIR}" data/
    print_ok "Backup created: backups/strapi_${ts}_full.tar.gz"
    
    echo -e "\n${BOLD}Backups:${NC}"
    ls -lh "$backup_dir"/*.tar.gz 2>/dev/null | tail -6
}

cmd_update() {
    check_env
    print_info "Updating..."
    dc pull
    dc up -d --force-recreate
    print_ok "Updated"
    cmd_status
}

cmd_shell() {
    docker exec -it "${1:-strapi-cms}" /bin/sh
}

cmd_clean() {
    read -p "Remove unused Docker resources? (y/N) " -n 1 -r
    echo
    [[ $REPLY =~ ^[Yy]$ ]] && docker system prune -f && print_ok "Cleaned"
}

cmd_help() {
    echo -e "\n${BOLD}Strapi CMS Management${NC}\n"
    echo "Usage: $0 <command>"
    echo ""
    echo "Commands:"
    echo "  start     Start services (auto-generates security keys)"
    echo "  stop      Stop services"
    echo "  restart   Restart services"
    echo "  status    Show status + data usage"
    echo "  logs [-f] [strapi|caddy]  View logs"
    echo "  health    Health check + data status"
    echo "  backup    Backup entire data directory"
    echo "  update    Pull latest & restart"
    echo "  shell     Open shell in container"
    echo "  clean     Remove unused Docker resources"
    echo ""
    echo "Data stored in: ${DATA_DIR}"
    echo ""
}

main() {
    check_docker
    case "${1:-help}" in
        start)   cmd_start ;;
        stop)    cmd_stop ;;
        restart) cmd_restart ;;
        status)  cmd_status ;;
        logs)    shift; cmd_logs "$@" ;;
        health)  cmd_health ;;
        backup)  cmd_backup ;;
        update)  cmd_update ;;
        shell)   cmd_shell "$2" ;;
        clean)   cmd_clean ;;
        *)       cmd_help ;;
    esac
}

main "$@"
