# terraform

## Notes

you must have `terraform` and `az` (azure) cli installed.
you must login `az login` and set the correct subscription.
then you must set the `ARM_ACCESS_KEY` to execute `terraform` commands, in linux/osx:

```bash
source ./access_key.sh
```

if resource group or account name changes, change them accordingly

## TODO

- [x] fix secrets for ci gh workflows
- [x] clean unusued modules
- [ ] upgrade providers to latest version (following migration guide)
- [ ] better organization of the filebase
- [x] double check that the backend is working correctly and that the saved state is as the real state
