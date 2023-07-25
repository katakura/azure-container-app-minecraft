using 'mc.bicep'

param baseName = 'minecraft'
param cpu = '1.0'
param memory = '2.0Gi'
param containerImage = 'docker.io/itzg/minecraft-server:latest'
param minecraftPort = 25565
param volumeMountPoint = '/data'
param minReplicas = 1
param env = [
  {
    name: 'EULA'
    value: 'TRUE'
  }
  {
    name: 'UID'
    value: '0'
  }
  {
    name: 'GID'
    value: '0'
  }
  {
    name: 'MAX_PLAYERS'
    value: '5'
  }
  {
    name: 'MODE'
    value: 'survival'
  }
  {
    name: 'DIFFICULTY'
    value: 'normal'
  }
]
