CURDIR := $(shell pwd)
UNAME := $(shell uname)
TF_PATH := $(CURDIR)/terraform
ANSIBLE_PATH := $(CURDIR)/ansible
ARCH := $(shell uname -m)
TOP := $(shell pwd)

export PATH := $(CURDIR)/bin/:$(CURDIR)/bin/$(UNAME):$(PATH)

SHELL := /bin/bash

PLAYBOOK_CMD = TF_STATE=$(TF_PATH)/infrastructure/prod/$(ENV) ansible-playbook --private-key=../keys/id_rsa --vault-password-file=../keys/ansible-vault -i ./inventory
ANSIBLE_CMD = TF_STATE=$(TF_PATH)/infrastructure/prod/$(ENV) ansible --private-key=../keys/id_rsa --vault-password-file=../keys/ansible-vault -i ./inventory

help: tasks

tasks:
	@grep -A1 ^HELP Makefile | gsed -e ':begin;$$!N;s/HELP: \(.*\)\n\(.*:\).*/\2 \1/;tbegin;P;D' | grep -v \\\-\\\- | sort | awk -F: '{printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

check-playbook:
ifndef PLAYBOOK
	$(error PLAYBOOK is not defined [PLAYBOOK=])
else
export _PLAYBOOK = plays/$(PLAYBOOK).yml
endif

check-limit:
ifndef LIMIT
export _LIMIT = --limit all
else
export _LIMIT = --limit $(LIMIT)
endif

check-env:
ifndef ENV 
	$(error ENV is not defined)
endif


HELP: Setup environment and refresh external roles
ansible/setup: check-env
	@cd $(ANSIBLE_PATH) ; \
	echo "Setting up Ansible Inventory" ; \
	echo "../bin/$(UNAME)/ansible-terragrunt-inventory" ; \
	echo "My DIR:" $(shell pwd) ; \
	echo "My ANSIBLE DIR:" $(ANSIBLE_PATH) ; \
	[[ -e "inventory" ]] || ln -s ../bin/$(UNAME)/ansible-terragrunt-inventory inventory ; \
	echo "" ; \
	echo "Creating host_vars/$(ENV).syzygy.ca from the example template" ; \
	[[ -f "host_vars/$(ENV).syzygy.ca" ]] || cp local_vars.yml.example host_vars/$(ENV).syzygy.ca ; \
	echo "" ; \
	echo "Update host_files/$(ENV).syzygy.ca to fit your environment." ; \
	echo "Installing external Ansible roles" ; \
	/bin/bash scripts/role_update.sh

HELP: Lists plays
ansible/list-playbooks:
	@cd $(ANSIBLE_PATH) ; \
	grep -RH ^## plays | gsed -e 's/\(plays\/\)\(.*\)\(.yml\)/\2/' | sort | awk 'BEGIN {FS = ":## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

HELP: Lists the tasks in a $PLAYBOOK for $ENV
ansible/list-tasks: check-playbook check-limit check-env
	@cd $(ANSIBLE_PATH) ; \
	$(PLAYBOOK_CMD) --list-tasks $(_LIMIT) $(_PLAYBOOK)

HELP: Lists all hosts in $ENV
ansible/hosts: check-env check-limit
	@cd $(ANSIBLE_PATH) ; \
	$(ANSIBLE_CMD) --list-hosts $(_LIMIT) all

HELP: List the hosts in $PLAYBOOK in $ENV
ansible/hosts/playbook: check-playbook check-limit check-env
	@cd $(ANSIBLE_PATH) ; \
	$(PLAYBOOK_CMD) $(_PLAYBOOK) $(_LIMIT) --list-hosts

HELP: Run $PLAYBOOK ON $ENV in check-mode
ansible/playbook/check: check-env check-playbook check-limit
	@cd $(ANSIBLE_PATH) ; \
	$(PLAYBOOK_CMD) --check --diff $(_LIMIT) $(_PLAYBOOK)

HELP: Run $PLAYBOOK ON $ENV
ansible/playbook: check-env check-playbook check-limit
	@cd $(ANSIBLE_PATH) ; \
	$(PLAYBOOK_CMD) $(_LIMIT) $(_PLAYBOOK)

