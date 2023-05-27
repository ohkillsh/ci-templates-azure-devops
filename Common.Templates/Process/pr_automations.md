# Examples

## Container with Automate Branch Update

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

stages:
  - stage: Build
    pool:
      name: ci-agent
    jobs:
      - job: Build
        steps:
          - template: Common.Templates/Build/build_container.yaml@ci-templates

  - stage: Automations
    pool: 
      vmImage: windows-latest
    jobs:
      - job: Automations
        steps:
          - template: Common.Templates/Build/automations.yaml@ci-templates

```