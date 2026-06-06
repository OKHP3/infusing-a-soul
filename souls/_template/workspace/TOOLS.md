# TOOLS.md -- [Persona Name] Connected Services

## 1. [Primary Model Provider]

- **Endpoint**: `http://[host]:[port]`
- **Role**: [Primary inference / fallback / specialized]
- **Model**: `[model-name]`
- **Notes**: [Runtime constraints, safety rules]

## 2. [Vector Database] (if applicable)

- **Endpoint**: `http://[host]:[port]`
- **Role**: [Semantic memory / document retrieval]
- **Usage rules**:
  - [Collection naming convention]
  - [Read/write permissions]
  - [Deletion policy]

## 3. [Search Provider] (if applicable)

- **Endpoint**: `http://[host]:[port]`
- **Role**: [Web search / knowledge lookup]
- **Usage rules**:
  - [When to use vs. local knowledge]
  - [Source citation policy]

## 4. [Channel / Interface]

- **Platform**: [Discord / Slack / CLI / Web]
- **Identity**: [Bot name and handle]
- **Owner**: [Authorized user]
- **Rules**:
  - [Response scope: owner-only vs. public]
  - [Message length constraints]
  - [Information disclosure policy]

<!-- List only services this persona connects to. Remove unused sections. -->
