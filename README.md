# terraform

## Notes
you must have `terraform` and `az` (azure) cli installed. 
you must login `az login` and set the correct subscription.
then you must set the `ARM_ACCESS_KEY` to execute `terraform` commands, in linux/osx:

```bash
export ARM_ACCESS_KEY=$(az storage account keys list --resource-group rg-polinetwork --account-name polinetworksa --query '[0].value' -o tsv)
```

if resource group or account name changes, change them accordingly

## TODO
- [ ] fix secrets for ci gh workflows
- [ ] clean unusued modules
- [ ] upgrade providers to latest version (following migration guide)
- [ ] better organization of the filebase
- [ ] double check that the backend is working correctly and that the saved state is as the real state 
