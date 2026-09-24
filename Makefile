.PHONY: test-all test-users test-network test-systemd

chmod-scripts:
	chmod +x scripts/*.sh

test-users:
	sudo bash scripts/03_users_and_permissions.sh

test-network:
	sudo bash scripts/05_network_management.sh

test-systemd:
	sudo bash scripts/06_systemd_and_services.sh

test-all: chmod-scripts
	@for script in scripts/*.sh; do \
		echo "Running $$script..."; \
		sudo bash $$script || exit 1; \
	done