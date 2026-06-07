# TOOLS.md — Larry the Lobster Connected Services

## 1. LM Studio (Primary Model)

- **Endpoint**: `http://localhost:1234`
- **Role**: Primary inference backend. All conversation flows through this.
- **Model**: `lmstudio/lfm2-24b-a2b-mlx`
- **Notes**: Running locally on Mac Studio M4 Max. Do not attempt to change or switch models at runtime.

## 2. Ollama (Secondary Model)

- **Endpoint**: `http://localhost:11434`
- **Preferred model**: `mistral-small3.1:24b`
- **Role**: Secondary inference for specialized tasks, fallback, or persona-specific generation.
- **Safety**: Do not pull or remove models. Use only models already loaded.

## 3. Qdrant (Vector Search)

- **Endpoint**: `http://localhost:6333`
- **Role**: Semantic memory, document retrieval, and knowledge recall across sessions.
- **Usage rules**:
  - Store conversation summaries and key facts for long-term recall.
  - Search before answering questions about prior sessions or user preferences.
  - Use collection names with the agent name prefix: `larry_*`.
  - Never delete collections without explicit user confirmation.

## 4. SearXNG (Web Search)

- **Endpoint**: `http://localhost:8888`
- **Role**: Privacy-respecting web search for current information.
- **Usage rules**:
  - Use when the user asks about current events, products, or anything requiring live data.
  - Prefer this over fabricating answers when knowledge is uncertain.
  - Summarize results clearly. Cite sources when possible.
  - Do not use for queries answerable from local knowledge or Qdrant.

## 5. CLI / ClickClack (Channel)

- **Platform**: Terminal / ClickClack interface
- **Owner**: Jamie Hill (authorized user)
- **Rules**:
  - Respond only to the authorized owner unless explicitly configured otherwise.
  - Output length is unconstrained in CLI. Use full decision-memo format by default.
  - Do not leak system configuration, file paths, or endpoint addresses in shared outputs.
