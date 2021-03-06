# To-dos

## Additional
- drupalExtraEnvVars
  - This should be spilt up:
    - drupalCommonEnvVars
    - drupalInstanceEnvVars
  - Similarly, drupalExtraSettings and the others should be like this
  - Reasoning: having a common.values.yaml, and a dev.values.yaml reduces the overhead and allows managing values in a single place for many instances.
- TBD: Configs with settings.php files which should be mounted:
    - Add them to the chart and refactor the settings to use getenv() for values that change
    - Add env vars for setting the individual values
    - Allow using existing configs
- TBD: Add secrets and other configs with placeholders only, add flag for only allowing them with `helm template`
    - This is needed for consistent resource names and labels.
- Debug why drupal-managed-premium-storage StorageClass doesn't work.
    - Note, this is not part of this repo.
- Auto-redeploy the deployment when configs/secrets change ([Doc](https://helm.sh/docs/howto/charts_tips_and_tricks/)):
    - `checksum/config: {{ include (print $.Template.BasePath "/configmap.yaml") . | sha256sum }}`
- Create a proper repo
    - https://tech.paulcz.net/blog/creating-a-helm-chart-monorepo-part-1/
- When possible, update to higher K8s version
    - Current: 1.15
    - Available in 1.16: startupProbe
- Autoscaler:
    ```
    apiVersion: autoscaling/v2beta2
    kind: HorizontalPodAutoscaler
    metadata:
      name: app-autoscaler
      namespace: reap
      labels:
        app: drupal-app
    spec:
      scaleTargetRef:
        apiVersion: apps/v1
        kind: Deployment
        name: drupal-app
      minReplicas: 1
      maxReplicas: 1
      metrics:
        - type: Resource
          resource:
            name: cpu
            target:
              type: Utilization
              averageUtilization: 75

    ```

# Research
- https://github.com/roboll/helmfile
- https://github.com/zegl/kube-score
- https://github.com/derailed/popeye
- https://kubernetes.io/blog/2019/07/18/api-deprecations-in-1-16/
- https://github.com/fairwindsops/nova

## Not necessarily Helm
- https://github.com/cloudquery/cloudquery