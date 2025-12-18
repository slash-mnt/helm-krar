# Kubernetes Resources Auto Rollout (krar) — Helm chart

`helm-krar` is a lightweight Helm chart that installs **krar** (“Kubernetes Resources Auto Rollout”), a simple mechanism to **trigger rollouts on selected Kubernetes workloads** so that images referenced by **floating tags** (e.g., `1.25`, `1`, `latest`) are refreshed regularly.

It can be considered a lightweight alternative to tools like Keel for the specific “refresh floating tags” use case.

For full application behavior and configuration semantics, see the upstream project: [**`slash-mnt/awesome-oci-images/tree/main/krar`**](https://github.com/slash-mnt/awesome-oci-images/tree/main/krar).

## What problem does this solve?

Kubernetes does **not** automatically restart workloads when a tag is re-published in a registry (for example, `nginx:1.25` being updated).  
krar periodically identifies marked resources and triggers a rollout so nodes re-pull images (when configured appropriately), keeping workloads aligned with the tag’s current digest.

## Key warnings and constraints

### Availability impact

> [!WARNING]
> Triggering a restart affects availability if:
>
> - There is only **one replica** of the resource.
> - The image tag is **too permissive** and may introduce breaking changes (e.g., `latest` or major version tags).

### Required: `imagePullPolicy: Always`

> [!IMPORTANT]
> Only workloads with `imagePullPolicy: Always` will behave as expected.

### Current limitations

At the moment, krar:

- Does not log events clearly
- Does not annotate restarted resources

## What’s inside this chart?

No dependencies required. The chart installs:

- Some **ServiceAccounts**
- Wether  **ClusterRole / ClusterRoleBinding** or **Role(s) / RoleBinding(s)** with limited permissions on:
  - core API group `""`, including only **Pods** and **Events**
  - `apps` API group, limited to at max **Deployments**, **DaemonSets**, **StatefulSets** and **ReplicaSets**
- One or more **CronJobs** (as many as you define) used to trigger rollouts

## Installation

### Prerequisites

- Kubernetes cluster with RBAC enabled
- Helm 3.x

### Install from a local clone

```bash
git clone https://github.com/slash-mnt/helm-krar.git
cd helm-krar

helm upgrade --install krar ./   --namespace krar   --create-namespace
```

### Install with custom values

```bash
helm upgrade --install krar ./   --namespace krar   --create-namespace   -f values.yaml
```

## How to mark resources for automatic rollout

With default values, add the following label to your **Deployment**, **DaemonSet**, or **StatefulSet**:

```yaml
krar.slash-mnt.com/rollout-policy: once-a-month
```

This label associates the resource with the CronJob named `once-a-month`.

It's also possible to target resources directly instead of adding an annotation on resources.

### Example (Deployment)

Note: requires a ServiceAccount and its ClusterRole/Roles.

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  labels:
    app: nginx
    krar.slash-mnt.com/rollout-policy: once-a-month
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
        - name: nginx
          image: nginx:1.25
          imagePullPolicy: Always
          ports:
            - containerPort: 80
```

## Configuration

Configuration is managed through `values.yaml`.

The chart supports defining **multiple rollout jobs**, each with its own schedule and selection policy. This enables patterns such as:

- Monthly refresh for low-risk services
- Nightly refresh in non-production namespaces
- Different policies per team or workload class

Customization follows the **krar application documentation** (see upstream repository).

For more information, please see [**`slash-mnt/awesome-oci-images/tree/main/krar`**](https://github.com/slash-mnt/awesome-oci-images/tree/main/krar).

## Upgrading and uninstalling

### Upgrade

```bash
helm upgrade krar ./ --namespace krar -f values.yaml
```

### Uninstall

```bash
helm uninstall krar --namespace krar
```

## License

MIT. See `LICENSE`.

## Maintainers

Maintained by **SLASH MNT**.
