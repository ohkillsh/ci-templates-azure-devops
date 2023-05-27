# ci-terraform

## Exemplo de criação de uma pipeline no Azure Devops

1. Você pode copiar todo o código abaixo e colar no seu arquivo ".yaml" em seu repositório.
2. Configurar os valores das variáveis
3. Executar a pipeline
4. Validar se a execução ficou tudo certo.

## variables

| Name | Value |
| -- | -- |
|TF-BACKEND-RESOURCEGROUP: |NOME DO RESOURCE GROUP DA ESTRUTURA BASE DO TERRAFORM |
|TF-BACKEND-STGNAME: |NOME DA STORAGE ACCOUNT DA ESTRUTURA BASE DO TERRAFORM|
|TF-BACKEND-STGCONTAINER: | terraform |
|TF-BACKEND-STGKEY: | NOME DO ARQUIVO DO STATE PARA ARMAZENAR DENTRO DO CONTAINER DA STOGARE ACCOUNT # Possíveis valores: | development.tfsate ou production.tfstate |
|TF-Keyvault-Name: |NOME DA KEY VAULT QUE CONTÉM AS SECRETS DO TERRAFORM|
|TF-Environment-Name: | NOME DO AMBIENTE CRIADO NO AZURE DEVOPS# Possíveis valores: | dev ou prod |
|TF-Path: | DIRETÓRIO DO REPOSITÓRIO QUE CONTÉM OS ARQUIVOS DO TERRAFORM/ # Aqui nós podemos executar o plan com arquivos .tfvars e separar os valores, ou utilizar WORKPATH |
|TF-Subscription-ID: |NOME DA SERVICE CONNNECTION# Service Connection vinculada a assinatura (Subscription-ID)para pipelines diferentes |
|tf_in_automation: | true |
|tf_parallelism: | 20 |

## Modelo YAML

<details>
<summary> Expandir para visualizar o código da pipeline </summary>

```yaml
name: 1.0.$(Rev:r)

trigger:
  branches:
    include:
      - main
  paths:
    include:
      - $(TF-PATH)

pool:
  vmImage: 'ubuntu-latest'

resources: 
  repositories:
  - repository: ci-templates
    type: github
    name: 
    endpoint: 
    ref: main

parameters: # Runtime Execution
  - name: runTFsec
    displayName: Run Terrafom TFsec?
    type: boolean
    default: false

  - name: runCheckChanges
    displayName: Run Terrafom CheckChanges?
    type: boolean
    default: false

variables:
  TF-BACKEND-RESOURCEGROUP: 
  TF-BACKEND-STGNAME: 
  TF-BACKEND-STGCONTAINER: "terraform"
  TF-BACKEND-STGKEY:
  TF-Keyvault-Name: 
  TF-Environment-Name: 
  TF-Path: 
  TF-Subscription-ID: 
  tf_in_automation: true
  tf_parallelism: 20

stages:
  - stage: PLAN
    displayName: "Terraform - Plan"
    jobs:
    - job:
      steps: 
        
        - template: Common.Templates/Process/pre_job.yaml@ci-templates
          parameters:
            Subscription-ID: $(TF-Subscription-ID)
            KeyVault-Name: $(TF-Keyvault-Name)
        - template: Common.Templates/Terraform/stage_plan.yaml@ci-templates

  - stage: APPLY
    jobs:
      - deployment: ApplyStage
        displayName: "Terraform - Apply"
        environment: $(TF-Environment-Name)
        workspace:
          clean: all
        strategy:
          runOnce:
            deploy:
              steps:
                - checkout: none
                - template: Common.Templates/Process/pre_job.yaml@ci-templates
                  parameters:
                    Subscription-ID: $(TF-Subscription-ID)
                    KeyVault-Name: $(TF-Keyvault-Name)
                - template: Common.Templates/Terraform/stage_apply.yaml@ci-templates
```

</details>
