# PRD #1: Umbrella Helm Chart for dot-ai Stack

**GitHub Issue**: [#1](https://github.com/vfarcic/dot-ai-stack/issues/1)
**Status**: Complete
**Priority**: Medium
**Created**: 2025-12-30

---

## Problem Statement

Users deploying the complete dot-ai stack must install multiple Helm charts separately:
- `dot-ai` - MCP server
- `dot-ai-controller` - Kubernetes controller
- `dot-ai-ui` - Web interface

This creates friction:
1. **Multiple install commands** - Users run 3 separate `helm install` commands
2. **Version coordination** - Users must manually ensure compatible versions
3. **Configuration scattered** - Related values spread across multiple releases
4. **Onboarding complexity** - New users must understand the relationship between components

---

## Solution Overview

Create an **umbrella Helm chart** (`dot-ai-stack`) that aggregates all three charts as dependencies:

```
dot-ai-stack/
├── Chart.yaml           # Dependencies on dot-ai, dot-ai-controller, dot-ai-ui
├── values.yaml          # Integration defaults
└── .github/workflows/
    └── release.yaml     # Package and publish to GHCR
```

**Key characteristics:**
- Individual charts remain standalone and independently releasable
- Umbrella chart provides convenience, not replacement
- Each component repo updates the umbrella on release
- Umbrella has its own semantic versioning

---

## Technical Design

### 1. Umbrella Chart Structure

```yaml
# Chart.yaml
apiVersion: v2
name: dot-ai-stack
description: Complete dot-ai stack - MCP server, controller, and UI
version: 0.1.0
appVersion: "0.1.0"

dependencies:
  - name: dot-ai
    version: "X.Y.Z"
    repository: "oci://ghcr.io/vfarcic"
  - name: dot-ai-controller
    version: "X.Y.Z"
    repository: "oci://ghcr.io/vfarcic"
  - name: dot-ai-ui
    version: "X.Y.Z"
    repository: "oci://ghcr.io/vfarcic"
```

### 2. Values Override Pattern

Users can override any sub-chart value by nesting under the dependency name:

```yaml
# user-values.yaml
dot-ai:
  replicaCount: 3
  resources:
    limits:
      memory: 4Gi

dot-ai-controller:
  watchNamespaces:
    - production

dot-ai-ui:
  ingress:
    enabled: true
    host: dot-ai.example.com
```

### 3. Auto-Update Workflow

Each component repo's release workflow will update the umbrella:

```yaml
# In dot-ai/.github/workflows/release.yaml (addition)
- name: Update umbrella chart
  run: |
    git clone https://github.com/vfarcic/dot-ai-stack.git
    cd dot-ai-stack
    # Update Chart.yaml dependency version for dot-ai
    yq -i '.dependencies[] | select(.name == "dot-ai") | .version = "${{ github.ref_name }}"' Chart.yaml
    git add Chart.yaml
    git commit -m "chore: bump dot-ai to ${{ github.ref_name }}"
    git push
```

### 4. Race Condition Handling

If two components release simultaneously:
- One push will fail due to conflict
- Manual resolution required (acceptable per discussion)
- Alternative: PR-based updates with auto-merge

---

## Scope

### In Scope

- Create new repository `dot-ai-stack`
- Minimal Chart.yaml with dependencies
- values.yaml with integration defaults (if needed)
- GHA workflow for packaging and publishing
- Update dot-ai, dot-ai-controller, dot-ai-ui release workflows
- Basic README with installation instructions

### Out of Scope

- Automated testing of the umbrella chart
- Compatibility matrix automation
- Breaking change detection between components

---

## Milestones

- [x] **M1: Create Repository and Chart Structure**
  - ~~Create `dot-ai-stack` repository~~ ✅
  - ~~Move this PRD to new repo~~ ✅
  - ~~Create Chart.yaml with dependencies~~ ✅
  - ~~Create minimal values.yaml~~ ✅

- [x] **M2: Release Workflow**
  - ~~Create GHA workflow to package chart~~ ✅
  - ~~Publish to GHCR as OCI artifact~~ ✅
  - ~~Test manual release process~~ ✅

- [x] **M3: Update Component Repos**
  - ~~Update dot-ai release workflow to bump umbrella~~ ✅
  - ~~Update dot-ai-controller release workflow~~ ✅
  - ~~Update dot-ai-ui release workflow~~ ✅
  - ~~Test end-to-end: component release triggers umbrella update~~ ✅

- [x] **M4: Documentation**
  - ~~Document installation in umbrella repo README~~ ✅
  - ~~Add reference in dot-ai docs~~ ✅
  - ~~Add reference in dot-ai-controller docs~~ ✅
  - ~~Add reference in dot-ai-ui docs~~ ✅
  - ~~Document values override pattern~~ ✅

---

## Open Questions (Resolve When Starting)

| Question | Options | Notes |
|----------|---------|-------|
| **Repo name** | `dot-ai-stack`, `dot-ai-umbrella`, `dot-ai-helm` | Affects chart name and URLs |
| **Chart name** | Same as repo? Different? | Convention is usually same as repo |
| **Registry** | Same GHCR org (`ghcr.io/vfarcic`)? | Consistency with existing charts |
| **Initial version** | `0.1.0`? Match highest component? | Semantic versioning strategy |
| **Integration defaults** | What values.yaml defaults needed? | e.g., service discovery between components |
| **Versioning on update** | Auto-bump patch? Manual? | When component updates, how to bump umbrella version |

---

## Dependencies

### Internal Dependencies
- dot-ai Helm chart (exists) ✅
- dot-ai-controller Helm chart (exists) ✅
- dot-ai-ui Helm chart (exists) ✅

### External Dependencies
- GitHub Actions for CI/CD
- GHCR for OCI artifact hosting

---

## Success Criteria

1. **Single install works**: `helm install dot-ai-stack oci://ghcr.io/vfarcic/dot-ai-stack` deploys all components
2. **Values override works**: Users can customize any sub-chart value
3. **Auto-update works**: Component release triggers umbrella version bump
4. **Documentation complete**: Users can find and follow installation guide

---

## Risks and Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Race conditions on concurrent releases | Low - manual resolution | Accept manual merge; consider PR-based updates later |
| Breaking changes between components | Medium | Require coordinated releases for majors |
| Umbrella version confusion | Low | Clear versioning docs; changelog noting component versions |
| ~~dot-ai-ui chart doesn't exist yet~~ | ~~Blocks full implementation~~ | ✅ Resolved - dot-ai-ui chart now exists |

---

## Decision Log

| Date | Decision | Rationale |
|------|----------|-----------|
| 2025-12-30 | **Accept manual race condition resolution** | Concurrent releases are rare; complexity of automation not worth it |
| 2025-12-30 | **Separate semantic versioning for umbrella** | Umbrella version represents the combination, independent of components |
| 2025-12-30 | **Coordinated releases for breaking changes** | Release dependencies first, then dependents |
| 2026-01-04 | **Include ResourceSyncConfig and CapabilityScanConfig by default** | Enables resource discovery and capability scanning out-of-the-box; configurable via `enabled` flags |
| 2026-01-04 | **Use fullnameOverride for consistent service names** | Ensures dot-ai-ui can connect to dot-ai service regardless of release name |
| 2026-01-04 | **Use Helm post-install hooks for CRs** | ResourceSyncConfig and CapabilityScanConfig use post-install/post-upgrade hooks to ensure CRDs from controller are installed first |
| 2026-01-04 | **Trigger website rebuild on doc changes** | Release workflow dispatches to dot-ai-website when README.md or docs/ change, consistent with other component repos |

---

## Current Status

**Last Updated**: 2026-01-04

**Status**: Complete (All Milestones Done)

### Completed
- M1: Chart structure with Chart.yaml, values.yaml, .helmignore
- Added ResourceSyncConfig and CapabilityScanConfig templates with Helm hooks
- Integration defaults for service discovery between components
- M2: Release workflow (.github/workflows/release.yaml) to package and publish to GHCR
- Release workflow triggers dot-ai-website rebuild when docs change
- Added Renovate configuration for automated GHA updates
- M3: All three component repos (dot-ai, dot-ai-controller, dot-ai-ui) now auto-update umbrella chart on release
- M4: Complete documentation - umbrella repo README, values override docs, and references added to all component repos (dot-ai, dot-ai-controller, dot-ai-ui)

### Next Steps
None - PRD complete!

---

## References

- [Helm Dependencies](https://helm.sh/docs/chart_best_practices/dependencies/)
- [OCI Registry Support](https://helm.sh/docs/topics/registries/)
- [kube-prometheus-stack](https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack) - Example umbrella chart
