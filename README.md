![](./assets/logo-small.png)

# Kubernetes Resources Auto Rollout aka krar

krar is a simple chart for refreshing images using floating tags on selected resources.
Can be considered as a lightweight Keel alternative.

The main use case is when your Kubernetes cluster is running applications/services using major or minor image
versions (floating tags) you want up to date on the application behind, go to 

For a full description look at the application sources [slash-mnt/krar](https://github.com/slash-mnt/awesome-oci-images/tree/main/krar).

> [!WARNING]
> Triggering that restart affects resource availability if:
> * There is only one replica of the resource,
> * The image version is too open and brings breaking changes risk (like `latest` or usually major versions).

> [!IMPORTANT]
> Only resources with `imagePullPolicy` set to `Always` will work.

It's possible to define multiple jobs to handle resources to restart in specific ways.

krar doesn't log events clearly nor annotate restart resources yet.

## What's inside?

**No dependency required.**

* ServiceAccount
* CluterRole/ClusterRoleBinding with GET, PATCH and LIST permissions on `""`, `"apps"` (deployments, daemonsets, statefulsets only)
* As many CronJob you need

## How to mark my resource for automatic rollout?

With default values, you can add the following label on your `Deployment`, `DaemonSet` and `StatefulSet` resources:

```yaml
krar.slash-mnt.com/rollout-policy: once-a-month
```

to allow auto rollout using the job named `once-a-month`.

Example:

```yaml
# From https://kubernetes.io/docs/concepts/workloads/controllers/deployment/
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
        ports:
        - containerPort: 80
```

Customization can be done following the [application documentation](https://github.com/slash-mnt/awesome-oci-images/tree/main/krar).