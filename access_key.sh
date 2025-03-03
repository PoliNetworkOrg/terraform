export ARM_ACCESS_KEY=$(az storage account keys list --resource-group rg-polinetwork --account-name polinetworksa --query '[0].value' -o tsv)
