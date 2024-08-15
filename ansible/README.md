`GROUP` corresponds to the directory heirarchy under `terraform/infrastructure`
(e.g. `prod` or `dev`). To configure a machine called test.syzygy.ca in the dev
group, we would do something like...

```bash
$ make playbook GROUP=dev HUB=test PLAYBOOK=init
$ make playbook GROUP=dev HUB=test PLAYBOOK=hub
```

If you are running on a Mac, you might run into an issue which crashes your
system python with a message about `__NSCFConstantString initialize` which is
covered by the [Ansible FAQ](https://docs.ansible.com/ansible/latest/reference_appendices/faq.html#running-on-macos-as-a-control-node). The short answer is to set
```bash
export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES
```
before running the hub playbook.
