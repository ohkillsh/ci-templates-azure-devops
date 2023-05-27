# Examples

## SonarQube Pipeline

```yaml
repositories:
  - repository: ci-templates
    type: github
    name: 
    endpoint: 
    ref: main

trigger: none
schedules: 
# CRON: Rodará apenas se houver novas mudanças na main desde a ultima execução. Recorrencia: Todo dia 8am de segunda a sexta :) 
- cron: "0 8 * * 1-5"
  displayName: Sonarqube Execution Task
  branches:
    include: 
    - main
    exclude:
    - develop
    - features/*
    - hotfix/*
    - QA
  always: false
pool:
  name: "AgentPoolCI"

parameters:
  - name: solution
    type: object
    default: 
      Solution: '**/*.sln'
  - name: SonarqubeProjectName
    default: "devops-microvix-$(Build.Repository.Name)"

stages:
  - stage: Build
    variables:
      buildPlatform: 'Any CPU'
      buildConfiguration: 'Release'

    jobs:

    - job: Build
      steps: 
      - template: Common.Templates/Build/sonarqube.yaml@ci-templates
        parameters:
          SolutionPath: ${{ parameters.solution }}
          SonarqubeProjectName: ${{ parameters.SonarqubeProjectName }}
          #runTests: 'false'
          #npm: false
          #env: null
          #csproj: null

```
