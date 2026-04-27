#!/bin/bash
set -e
error() {
	echo "🎃 Failed !!!"
}
trap error ERR

log_info() {
    TIMESTAMP=$(date --iso-8601=ns)
    echo -e "$TIMESTAMP | $*"
}

if [[ -n "$ENABLE_K8S" ]];
then
	log_info "⏳ Wait for linuxdev."
	until nc -zv msa-dev 22; do
		sleep 10
		log_info "⏳ Wait for linuxdev."
	done
fi
cd / || exit 1

if [[ -L /opt/fmc_repository/CommandDefinition/paloalto-prisma-ms ]]; then
	SYMLINK_TARGET=$(readlink -f /opt/fmc_repository/CommandDefinition/paloalto-prisma-ms || true)
	if [[ -n "$SYMLINK_TARGET" && -e "$SYMLINK_TARGET/.git" ]]; then
		log_info "🌹 Symlink and git repo found."
	else
		log_info "🦥 Removing symlink."
		rm -f /opt/fmc_repository/CommandDefinition/paloalto-prisma-ms
	fi
fi

# for backward compatibility with old backend, move existing repository to CommandDefinition
if [[ -e /opt/fmc_repository/paloalto-prisma-ms/.git ]]; then
	log_info "🦖 Moving existing git repository to /opt/fmc_repository/CommandDefinition for backend compatibility."
	mkdir -p /opt/fmc_repository/CommandDefinition
	if [[ -e /opt/fmc_repository/CommandDefinition/paloalto-prisma-ms ]]; then
		log_info "🍄 Removing existing destination directory before move."
		rm -rf /opt/fmc_repository/CommandDefinition/paloalto-prisma-ms
	fi
	mv /opt/fmc_repository/paloalto-prisma-ms /opt/fmc_repository/CommandDefinition/paloalto-prisma-ms
elif [[ -d /opt/fmc_repository/paloalto-prisma-ms ]]; then
	log_info "🐞 Not a git repository. Removing the directory for backend compatibility."
	rm -rf  /opt/fmc_repository/paloalto-prisma-ms
fi

if [[ -e /opt/fmc_repository/CommandDefinition/cloudflare-ms/.git ]]; then
	log_info "🦔 Skipping upgrade for fellow developer."
	exit 0
fi
#tar --overwrite --no-same-owner -xf /home/ncuser/fmc-repository.tar.xz -I 'xz -T0' --checkpoint=1000 --checkpoint-action=ttyout='%{%Y-%m-%d %H:%M:%S}t⏳ \033[1;37m(%d sec)\033[0m: \033[1;32m#%u\033[0m, \033[0;33m%{}T\033[0m\r'
tar --overwrite --no-same-owner -xf /home/ncuser/fmc-repository.tar.xz -I 'xz -T0' --checkpoint=1000 --checkpoint-action=echo='%{%Y-%m-%d %H:%M:%S}t⏳ \033[1;37m(%d sec)\033[0m: \033[1;32m#%u\033[0m, \033[0;33m%{}T\033[0m'
echo "✅ Success ..."


