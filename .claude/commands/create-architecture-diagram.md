# Create Architecture Diagram

Create a detailed architecture diagram for the **$ARGUMENTS** tool/feature.

## Instructions

1. **Research the feature** from source code in the parent directory projects:
   - `../dot-ai/` - MCP Server (main tools in `src/tools/`)
   - `../dot-ai-controller/` - Kubernetes Controller
   - `../dot-ai-ui/` - Web UI
   - Documentation at https://devopstoolkit.ai/

2. **Create the architecture document** at `docs/architecture/{feature-name}.md` with:

   ### High-Level Architecture (Mermaid)
   - Show components as subgraphs: User/Agent, MCP Server, External Services, Kubernetes, Web UI
   - Use "etc." for non-exhaustive lists (agents, LLMs, resources)
   - Arrow from Agent to the specific tool via MCP Protocol
   - Show internal tool dependencies (AI Provider, Vector DB Client, Discovery Engine)
   - Show external connections (LLM APIs, Qdrant with embeddings, K8s API)
   - Controller syncs data to Qdrant with embeddings
   - User opens Visualization URL in Web UI (dotted arrow from Agent)

   ### Workflow Stages (Mermaid)
   - Show the complete workflow with all stages
   - Include decision points and branching logic
   - Show retry loops where applicable
   - Group related steps in subgraphs

3. **Include supporting sections**:
   - Component Details (table with files and descriptions)
   - Integration Points (Mermaid diagram + bullet points)
   - Session Management (if applicable)
   - Output Formats (if applicable)
   - Error Handling
   - See Also (links to related docs)

4. **Diagram guidelines**:
   - Use Mermaid `flowchart` (TB for vertical, LR for horizontal)
   - Use subgraphs to group related components
   - Use decision nodes `{}` for branching
   - Keep labels concise, use `<br/>` for line breaks
   - Avoid redundancy between diagrams

## Usage

```
Create architecture diagram for {tool-name}
```

Example: `Create architecture diagram for remediate`
