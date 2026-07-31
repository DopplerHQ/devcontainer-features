
# Prepare Volume Permissions (volume-permissions)

Creates directories and takes ownership of them as the remote user. Useful for prepping volume mounts in environments where the hosts's UID does not match the remote user's UID.

## Example Usage

```json
"features": {
    "ghcr.io/DopplerHQ/devcontainer-features/volume-permissions:1": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| basePath | Base path to prepend to every `paths` value. | string | - |
| paths | Comma-separated list of paths to chown as the remote user. | string | - |


## Examples

### Basic Usage

This demonstrates prepping folders that may or may not already exist on the host, and ensures that all `paths` get initialized as empty volumes which are writable within the container.

```jsonc
{
  "remoteUser": "vscode",
  "updateRemoteUserUID": false, // can be true on osx only
  "features": {
    "ghcr.io/DopplerHQ/devcontainer-features/volume-permissions:1": {
      "basePath": "${containerWorkspaceFolder}",
      "paths": ".pnpm-store,node_modules"
    }
  },
  "mounts": [
    {
      "type": "volume",
      "source": "${localWorkspaceFolderBasename}-pnpm-store",
      "target": "${containerWorkspaceFolder}/.pnpm-store"
    },
    {
      "type": "volume",
      "source": "${localWorkspaceFolderBasename}-node-modules",
      "target": "${containerWorkspaceFolder}/node_modules"
    }
  ]
}
```

### Volume Subpath Support

This demonstrates using a single volume to store everything volume-mounted in the container. Note that with this approach, if you ever add new subpath mounts, you will need to delete the volume to have it be recreated by this feature. This is useful if you don't like having many volumes get created for each container.

```jsonc
{
  "remoteUser": "vscode",
  "updateRemoteUserUID": false, // can be true on osx only
  "features": {
    "ghcr.io/DopplerHQ/devcontainer-features/volume-permissions:1": {
      "basePath": "/shared-volume",
      "paths": ".pnpm-store,node_modules"
    }
  },
  "mounts": [
    "type=volume,source=${localWorkspaceFolderBasename}-shared-mount,target=/shared-volume",
    "type=volume,source=${localWorkspaceFolderBasename}-shared-mount,target=${containerWorkspaceFolder}/.pnpm-store,volume-subpath=./.pnpm-store",
    "type=volume,source=${localWorkspaceFolderBasename}-shared-mount,target=${containerWorkspaceFolder}/node_modules,volume-subpath=./node_modules",
  ]
}
```

---

_Note: This file was auto-generated from the [devcontainer-feature.json](devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
