# terraform


to execute terraform init before you need to run this cmd:

```bash
export ARM_ACCESS_KEY=$(az storage account keys list --resource-group rg-polinetwork --account-name polinetworksa --query '[0].value' -o tsv)
```

if resource group or account name changes, change them accordingly
