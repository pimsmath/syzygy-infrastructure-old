UNAME := $(shell uname | tr '[:upper:]' '[:lower:]')
ARCH := $(shell uname -m)
TOP := $(shell pwd)
TF_PATH := $(TOP)/../terraform

GROUP ?= prod

PLAYBOOK_CMD = TF_STATE=$(TF_PATH)/infrastructure/$(GROUP)/$(ENV) ansible-playbook --private-key=../keys/id_rsa --vault-password-file=../keys/ansible-vault -i ./inventory
ANSIBLE_CMD = TF_STATE=$(TF_PATH)/infrastructure/$(GROUP)/$(ENV) ansible --private-key=../keys/id_rsa --vault-password-file=../keys/ansible-vault -i ./inventory

help: tasks

tasks:
	@grep -A1 ^HELP Makefile | gsed -e ':begin;$$!N;s/HELP: \(.*\)\n\(.*:\).*/\2 \1/;tbegin;P;D' | grep -v \\\-\\\- | sort | awk -F: '{printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'


export PATH := $(TF_PATH)/bin/$(UNAME):$(PATH)

check-playbook:
ifndef PLAYBOOK
	$(error PLAYBOOK is not defined [PLAYBOOK=])
else
export _PLAYBOOK = plays/$(PLAYBOOK).yml
endif

check-env:
ifndef ENV
	$(error ENV is not defined)
endif

check-limit:
ifndef LIMIT
export _LIMIT = --limit all
else
export _LIMIT = --limit $(LIMIT)
endif

check-tags:
ifndef TAGS
export _TAGS =
else
export _TAGS =--tags $(TAGS)
endif

HELP: Setup environment and refresh external roles
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

HELP: Lists plays
list-playbooks:
	@grep -RH ^## plays | gsed -e 's/\(plays\/\)\(.*\)\(.yml\)/\2/' | sort | awk 'BEGIN {FS = ":## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

HELP: Lists all hosts in $ENV
hosts: check-env check-limit
	$(ANSIBLE_CMD) --list-hosts $(_LIMIT) all

HELP: Run $PLAYBOOK ON $ENV
playbook: check-env check-playbook check-limit check-tags
	$(PLAYBOOK_CMD) $(_LIMIT) $(_PLAYBOOK) $(_TAGS)

HELP: Run $PLAYBOOK ON $ENV in check-mode
playbook/check: check-env check-playbook check-limit check-tags
	$(PLAYBOOK_CMD) --check --diff $(_LIMIT) $(_PLAYBOOK) $(_TAGS)
