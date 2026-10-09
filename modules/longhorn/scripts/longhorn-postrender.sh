#!/bin/sh
set -eu

# Pinned chart 1.8.1 omits persistence.backupTargetName from its StorageClass
# ConfigMap. Fail closed if the rendered shape changes in a future upgrade.
awk '
  /^---$/ { storageclass = 0 }
  /^  name: longhorn-storageclass$/ { storageclass = 1 }
  storageclass && /^      backupTargetName:/ { unexpected = 1 }
  { print }
  storageclass && /^      numberOfReplicas:/ {
    print "      backupTargetName: \"azblob\""
    inserted++
  }
  END {
    if (inserted != 1 || unexpected) {
      print "Unexpected Longhorn StorageClass template; review the postrenderer" > "/dev/stderr"
      exit 1
    }
  }
'
