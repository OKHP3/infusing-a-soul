# TOOLS.md — Glee-fully Connected Services

## 1. LM Studio (Primary Model)

- **Endpoint**: `http://10.10.1.201:1234`
- **Role**: Primary inference backend. All conversation flows through this.
- **Model**: `lmstudio/mistral-small-3.2-24b-instruct-2506-mlx` (fallback: `ollama-local/granite4.1:3b` on the laptop)
- **Notes**: Running on Mac Studio M4 Max. Do not attempt to change or switch models at runtime.

## 2. Ollama (Persona Model)

- **Endpoint**: `http://10.10.1.201:11434`
- **Preferred model**: `mistral-small3.1:24b`
- **Role**: Available as secondary inference for persona-specific tasks or fallback.
- **Safety**: Do not pull or remove models. Use only models already loaded.

## 3. Qdrant (Vector Search)

- **Endpoint**: `http://10.10.1.201:6333`
- **Role**: Semantic memory and vector search for session context, document retrieval, and knowledge recall.
- **Usage rules**:
  - Store conversation summaries and key facts for long-term recall.
  - Search before answering questions about prior sessions or user preferences.
  - Use collection names that include the agent name prefix: `gleefully_*`.
  - Never delete collections without explicit user confirmation.

## 4. SearXNG (Web Search)

- **Endpoint**: `http://10.10.1.201:8888`
- **Role**: Privacy-respecting web search for current information.
- **Usage rules**:
  - Use when the user asks about current events, products, prices, or anything requiring live data.
  - Prefer this over fabricating answers when knowledge is uncertain.
  - Summarize results clearly. Cite sources when possible.
  - Do not use for queries that can be answered from local knowledge or Qdrant.

## 5. Discord (Channel)

- **Server**: OverKill Hill P3
- **Bot**: Glee-fully#4667
- **Owner**: Jamie Hill (authorized user)
- **Rules**:
  - Respond only to the authorized owner unless explicitly configured otherwise.
  - Keep responses concise in Discord. Long outputs should offer to continue or be chunked.
  - Do not leak system configuration, file paths, or endpoint addresses in Discord responses.
