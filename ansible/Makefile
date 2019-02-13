UNAME := $(shell uname)
TOP := $(shell pwd)
TF_PATH := $(TOP)/../terraform

PLAYBOOK_CMD = TF_STATE=$(TF_PATH)/infrastructure/prod/$(env) ansible-playbook --private-key=../keys/id_rsa --vault-password-file=../keys/ansible-vault -i ./inventory
ANSIBLE_CMD = TF_STATE=$(TF_PATH)/infrastructure/prod/$(env) ansible --private-key=../keys/id_rsa --vault-password-file=../keys/ansible-vault -i ./inventory

export PATH := $(TF_PATH)/bin/$(UNAME):$(PATH)

check-env:
ifndef env
	$(error env is not defined)
endif

setup: check-env
	@echo "Setting up Ansible Inventory"
	[[ -e "inventory" ]] || ln -s ./bin/$(UNAME)/ansible-terraform-inventory inventory
	@echo ""
	@echo "Creating host_vars/<env>.syzygy.ca from the example template"
	[[ -f "host_vars/local_vars.yml" ]] || cp local_vars.yml.example host_vars/$(env).syzygy.ca
	@echo ""
	@echo "Update host_files/<env>.syzygy.ca to fit your environment."
	@echo "Don't forget to set dehydrate_test_cert to False if you're sure Let's Encrypt is working."
	@echo "Press enter to continue"
	@read
	@echo "Installing external Ansible roles"
	/bin/bash scripts/role_update.sh

list-init-tasks:
	ansible-playbook --list-tasks plays/init.yml

list-update-tasks:
	ansible-playbook --list-tasks plays/update.yml

list-hub-tasks:
	ansible-playbook --list-tasks plays/hub.yml

hub/init/check: check-env
	$(PLAYBOOK_CMD) --limit hub --check --diff plays/init.yml

hub/init/apply: check-env
	$(PLAYBOOK_CMD) --limit hub plays/init.yml

hub/update/check: check-env
	$(PLAYBOOK_CMD) --limit hub --check --diff plays/update.yml

hub/update/apply: check-env
	$(PLAYBOOK_CMD) --limit hub plays/update.yml

hub/check: check-env
	$(PLAYBOOK_CMD) --limit hub --check --diff plays/hub.yml

hub/apply: check-env
	$(PLAYBOOK_CMD) --limit hub plays/hub.yml

stats-server/init/check: check-env
	$(PLAYBOOK_CMD) --limit stats --check --diff plays/init.yml

stats-server/init/apply: check-env
	$(PLAYBOOK_CMD) --limit stats plays/init.yml

stats-server/update/check: check-env
	$(PLAYBOOK_CMD) --limit stats --check --diff plays/update.yml

stats-server/update/apply: check-env
	$(PLAYBOOK_CMD) --limit stats plays/update.yml

stats-server/check: check-env
	$(PLAYBOOK_CMD) --limit stats --check --diff plays/stats-server.yml

stats-server/apply: check-env
	$(PLAYBOOK_CMD) --limit stats plays/stats-server.yml

stats-client/check: check-env
	$(PLAYBOOK_CMD) --limit hub --check --diff plays/stats-client.yml

stats-client/apply: check-env
	$(PLAYBOOK_CMD) --limit hub plays/stats-client.yml
