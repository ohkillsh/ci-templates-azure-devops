# Como utilizar

## Definindo estrutura do CI

Essa estruta deverá existir em um repositório GIT no Azure DevOps.
É necessário a padronização, para poder reproduzir ela de forma automatizada em escala.

1. O diretório .azdevops deverá ser utilizado para recursos do Azure DevOps, para conter informações do CI/CD.
2. Os arquivos .yaml, deveram ser parametrizados conforme guia abaixo.


```bash
├── .azdevops
│   ├── parameters.yaml
│   ├── sonarqube.yaml
│   ├── prod.yaml
│   ├── dev.yaml
└── src
└── .gitignore
```

<br />

## File - Parameters.yaml

### Aplicação Javascript

<details> <summary> Expandir para visualizar o código da pipeline - Aplicação Javascript </summary>

```yaml
parameters:
  - name: env
    type: object
    default:
      VueJs_WebApp_1: "production"
      VueJs_WebApp_2: "production"
  - name: node
    type: object
    default:
      version: "12.22.1"

steps:
  - template: Common.Templates/Build/build.yaml@ci-templates
    parameters:
      npm: true
      env: ${{ parameters.env }}
      node: ${{ parameters.node }}

```

</details>

### Aplicação dotnet

<details> <summary> Expandir para visualizar o código da pipeline - Aplicação dotnet </summary>

```yaml
parameters:
  - name: artifacts
    type: object
    default:
      Dotnet_1: 'Source\dotnet_1\Dotnet_1.app\obj\Release'
      Dotnet_2: 'Source\dotnet_2\Dotnet_2.App\obj\Release'
      
  - name: solution
    type: object
    default: 
      Solution: '**/*.sln'

steps: 
    - template: Common.Templates/Build/build.yaml@ci-templates
      parameters:
        artifactsToPublish: ${{ parameters.artifacts }}
        SolutionPath: ${{ parameters.solution }}

```

</details>

<br /><br />

## File - sonarqube.yaml

<details> <summary> Expandir para visualizar o código da pipeline </summary>

```yaml

```

</details>

<br /><br />

## File - prod.yaml

Esse é o pipeline para artefatos de ambientes produtivos.
Nele conterá processos e stages especificos de ambiente UAT e PRODUCTION.

<details> <summary> Expandir para visualizar o código da pipeline </summary>

```yaml
repositories:
  - repository: ci-templates
    type: github
    name: 
    endpoint: 
    ref: main

trigger:
  branches:
    include:
      - main
      - develop
      - QA
    exclude:
      - hotfix/*
      - features/*
  paths:
    exclude:
    - '.azdevops/*'
    - '**/*.yaml'
    - '**/*.yml'



stages:
  - stage:
    variables:
      buildPlatform: "Any CPU"
      buildConfiguration: "Release"

    jobs:
      - job: WorkItem
        pool:
          name: windows-latest
        steps:
          - checkout: none
          - template: Common.Templates/Process/workitem_automation.yaml@ci-templates

      - job: Build
        pool:
          name: ci-agent
        dependsOn: WorkItem
        condition: eq(dependencies.WorkItem.result,'Succeeded')
        steps:
          - template: parameters.yaml

      - job: PR
        pool:
          name: windows-latest
        dependsOn: Build
        condition: eq(dependencies.Build.result,'Succeeded')
        steps:
          - checkout: none
          - template: Common.Templates/Process/pr_automation.yaml@ci-templates

```

</details>

<br /><br />

## File - dev.yaml

Esse é o pipeline para artefatos de ambientes de desenvolvimento.

<details> <summary> Expandir para visualizar o código da pipeline </summary>

```yaml
resources:
    repositories:
    - repository: ci-templates
        type: github
        name: 
        endpoint: 
        ref: main

trigger:
  branches:
    include:
      - featues/*
      - bugfix/*
    exclude:
      - main
      - develop
      - QA
  paths:
    exclude:
    - '.azdevops/*'
    - '**/*.yaml'
    - '**/*.yml'

stages:
  - stage:
    variables:
      buildPlatform: "Any CPU"
      buildConfiguration: "Release"
    pool:
      name: ci-agents

    jobs:
      - job: Build
        steps:
          - template: parameters.yaml

```

</details>

<br /><br />
