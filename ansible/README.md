`GROUP` corresponds to the directory heirarchy under `terraform/infrastructure`
(e.g. `prod` or `dev`). To configure a machine called test.syzygy.ca in the dev
group, we would do something like...

```bash
$ make playbook GROUP=dev HUB=test PLAYBOOK=init
$ make playbook GROUP=dev HUB=test PLAYBOOK=hub
```

