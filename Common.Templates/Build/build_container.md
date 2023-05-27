# How to build_container temmplate

## reques

- Adicionar service connection com o registry 

```yaml
TYPE: OTHERS
DOCKER REGISTRY: https://myacr.azurecr.io
Docker ID: myacr
Docker Password: '****'

```

```yaml
name: $(Build.DefinitionName)-$(Build.BuildId)

repositories:
  - repository: ci-templates
    type: github
    name: 
    endpoint: 
    ref: main

variables:

trigger: 
      branches:
        include: 
        - main
        - develop
        - QA
        exclude:
        - hotfix/*
        - features/*

parameters:
  - name: artifacts
    type: object
    default:
      default: ''
  - name: solution
    type: object
    default: 
      Solution: '**/*.sln'

pool:
  name: win-container 


stages:
  - stage: Build
    variables:
      buildPlatform: 'Any CPU'
      buildConfiguration: 'Release'
      
    jobs:

    - job: Build
      steps: 

      - task: AzureKeyVault@2
        inputs:
          azureSubscription: ""
          KeyVaultName: ""
          SecretsFilter: "*"
          RunAsPreJob: true
   
      - template: Common.Templates/Build/build_container.yaml@ci-templates
        parameters:
          containerRegistryName: "cr-myacr-eastus"
          containerRepository: "container/app/v1"
  
```
