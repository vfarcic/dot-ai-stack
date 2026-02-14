# DevOps AI Toolkit Stack

**Deploy the complete DevOps AI Toolkit stack with a single Helm command.**

## Overview

The dot-ai-stack umbrella chart installs all DevOps AI Toolkit components with a single command:
- **DevOps AI Toolkit** - MCP server for AI-powered Kubernetes operations
- **DevOps AI Toolkit Controller** - Kubernetes controller for intelligent resource management and autonomous operations
- **DevOps AI Toolkit Web UI** - Web interface for visual cluster management

> **Note:** This guide covers Kubernetes deployment using the umbrella Helm chart. For other installation options (Docker, NPX, individual charts, etc.), see [devopstoolkit.ai](https://devopstoolkit.ai).

## Prerequisites

- **Kubernetes cluster** with an ingress controller
- **Helm 3.x** installed
- **kubectl** configured with cluster access
- **AI API keys** for AI-powered features (Anthropic and/or OpenAI)

## Step 1: Create a Local Cluster (Optional)

> Skip this step if you already have a Kubernetes cluster with an ingress controller.

Create a Kind cluster with ingress port mappings:

```bash
kind create cluster --name dot-ai-stack --config - <<EOF
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  extraPortMappings:
  - containerPort: 80
    hostPort: 80
    protocol: TCP
  - containerPort: 443
    hostPort: 443
    protocol: TCP
EOF
```

You should see output ending with:

```
Set kubectl context to "kind-dot-ai-stack"
```

Install the nginx ingress controller for Kind:

```bash
kubectl apply \
    --filename https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
```

Wait for the ingress controller to be ready:

```bash
kubectl wait --namespace ingress-nginx \
    --for=condition=ready pod \
    --selector=app.kubernetes.io/component=controller \
    --timeout=90s
```

## Step 2: Set Environment Variables

Set your API keys for AI-powered features:

```bash
export ANTHROPIC_API_KEY="your-anthropic-api-key"

export OPENAI_API_KEY="your-openai-api-key"
```

> **Note:** Multiple AI providers are supported. See [AI Model Configuration](https://devopstoolkit.ai/docs/mcp/setup/mcp-setup/#ai-model-configuration) for all options including Google Gemini, AWS Bedrock, Azure OpenAI, and others.

Generate random authentication tokens for the MCP server and Web UI:

```bash
export DOT_AI_AUTH_TOKEN=$(openssl rand -base64 32)

export DOT_AI_UI_AUTH_TOKEN=$(openssl rand -base64 32)
```

## Step 3: Install the Stack

Install the complete dot-ai stack with a single Helm command:

```bash
helm upgrade --install dot-ai-stack \
    oci://ghcr.io/vfarcic/dot-ai-stack/charts/dot-ai-stack \
    --namespace dot-ai --create-namespace \
    --set dot-ai.secrets.anthropic.apiKey=$ANTHROPIC_API_KEY \
    --set dot-ai.secrets.openai.apiKey=$OPENAI_API_KEY \
    --set dot-ai.secrets.auth.token=$DOT_AI_AUTH_TOKEN \
    --set dot-ai.ingress.enabled=true \
    --set dot-ai.ingress.className=nginx \
    --set dot-ai.ingress.host=dot-ai.127.0.0.1.nip.io \
    --set dot-ai.webUI.baseUrl=http://dot-ai-ui.127.0.0.1.nip.io \
    --set dot-ai-ui.uiAuth.token=$DOT_AI_UI_AUTH_TOKEN \
    --set dot-ai-ui.ingress.enabled=true \
    --set dot-ai-ui.ingress.host=dot-ai-ui.127.0.0.1.nip.io \
    --wait
```

> **Note:** Replace the ingress hosts with your actual domain names for production deployments.

This installs:
- **dot-ai** - MCP server with ingress at `dot-ai.127.0.0.1.nip.io`
- **dot-ai-controller** - Kubernetes controller for autonomous operations
- **dot-ai-ui** - Web interface at `dot-ai-ui.127.0.0.1.nip.io`
- **Qdrant** - Vector database for pattern and policy storage
- **ResourceSyncConfig** - Enables resource discovery
- **CapabilityScanConfig** - Enables cluster capability scanning

## Step 4: Verify Installation

Check that all pods are running:

```bash
kubectl get pods --namespace dot-ai
```

You should see all pods in `Running` status:

```
NAME                                        READY   STATUS    RESTARTS   AGE
dot-ai-577db5b4fc-j8kgf                     1/1     Running   0          50s
dot-ai-controller-manager-c898b5697-dqk2m   1/1     Running   0          50s
dot-ai-stack-qdrant-0                       1/1     Running   0          50s
dot-ai-ui-69d586db8b-ccqrm                  1/1     Running   0          50s
```

Test the MCP server health:

```bash
curl -H "Authorization: Bearer $DOT_AI_AUTH_TOKEN" \
    http://dot-ai.127.0.0.1.nip.io/healthz
```

Expected output:

```json
{"status":"ok"}
```

## Step 5: Choose Your Client

The DevOps AI Toolkit can be accessed through two client options - **MCP** or **CLI**. Both provide AI agent integration with full feature parity.

### Option A: MCP Client

**Best for:** Curated high-level operations designed to minimize context window usage.

Create the MCP client configuration file:

```bash
cat > .mcp.json << EOF
{
  "mcpServers": {
    "dot-ai": {
      "type": "http",
      "url": "http://dot-ai.127.0.0.1.nip.io",
      "headers": {
        "Authorization": "Bearer $DOT_AI_AUTH_TOKEN"
      }
    }
  }
}
EOF
```

> **Note:** This example creates `.mcp.json` in the current directory for Claude Code. Other MCP-enabled agents may expect the configuration in a different location (e.g., `~/.config/` or within the agent's settings). Consult your agent's documentation for the correct path.

**Learn more:** [MCP Setup Documentation](https://devopstoolkit.ai/docs/mcp/setup/mcp-setup/)

### Option B: CLI Client

**Best for:** Comprehensive API access with lower token overhead for AI agents, plus scripting and automation support.

Install the CLI:

**macOS (Homebrew):**
```bash
brew install vfarcic/tap/dot-ai
```

**Windows (Scoop):**
```powershell
scoop bucket add dot-ai https://github.com/vfarcic/scoop-dot-ai
scoop install dot-ai
```

**Other platforms:** Download from [releases](https://github.com/vfarcic/dot-ai-cli/releases) or see [installation guide](https://devopstoolkit.ai/docs/cli/setup/installation/).

Configure the CLI:

```bash
export DOT_AI_URL="http://dot-ai.127.0.0.1.nip.io"
```

Generate skills for your AI agent:

```bash
# For Claude Code
dot-ai skills generate --agent claude-code

# For Cursor
dot-ai skills generate --agent cursor

# For Windsurf
dot-ai skills generate --agent windsurf
```

**Learn more:** [CLI Quick Start](https://devopstoolkit.ai/docs/cli/quick-start/) | [Installation](https://devopstoolkit.ai/docs/cli/setup/installation/) | [Agent Integration](https://devopstoolkit.ai/docs/cli/setup/agent-integration/)

### Choosing Between MCP and CLI

- **Use MCP** for simpler, high-level operations with minimal tool descriptions
- **Use CLI** for comprehensive API access with lower token costs and better economy for agents executing multiple commands

## Step 6: Start Using

Launch your AI agent:

```bash
claude
```

> **Note:** If your agent doesn't automatically detect the client, explicitly invoke it with "Use dot-ai MCP" or "Use dot-ai CLI" depending on which client you configured.

Try these example prompts:

| What You Want | Example Prompt |
|---------------|----------------|
| Check system status | "Show dot-ai status" |
| Query cluster | "What pods are running in the dot-ai namespace?" |
| List capabilities | "List all capabilities" |
| Deploy an app | "I want to deploy a web application" |
| Fix issues | "Something is wrong with my database" |

## Configuration

Override any component value by prefixing with the chart name:

```bash
--set dot-ai.resources.limits.memory=4Gi
--set dot-ai-controller.resources.limits.memory=1Gi
--set dot-ai-ui.ingress.host=ui.example.com
```

For available options, see each component's documentation:
- [DevOps AI Toolkit values](https://devopstoolkit.ai/docs/mcp/setup/mcp-setup/)
- [Controller values](https://devopstoolkit.ai/docs/controller/)
- [Web UI values](https://devopstoolkit.ai/docs/ui/)

## Next Steps

- [MCP Tools Overview](https://devopstoolkit.ai/docs/mcp/guides/mcp-tools-overview/) - Complete feature reference
- [Pattern Management](https://devopstoolkit.ai/docs/mcp/guides/pattern-management-guide/) - Create organizational patterns
- [Policy Management](https://devopstoolkit.ai/docs/mcp/guides/policy-management-guide/) - Define governance policies

## Cleanup

To remove the stack:

```bash
helm uninstall dot-ai-stack --namespace dot-ai

kubectl delete namespace dot-ai
```

To delete the Kind cluster:

```bash
kind delete cluster --name dot-ai-stack
```
