# To-dos

## Global

- Linux/Cluster hardening
  - https://media.defense.gov/2021/Aug/03/2002820425/-1/-1/1/CTR_KUBERNETESHARDENINGGUIDANCE.PDF
  - https://kubernetes.io/docs/tasks/administer-cluster/securing-a-cluster/
  - https://www.stackrox.io/blog/kubernetes-security-101/
  - https://bridgecrew.io/blog/scan-helm-charts-for-kubernetes-misconfigurations-with-checkov/
  - https://cloud.google.com/kubernetes-engine/docs/how-to/hardening-your-cluster

## Main
- Set up immutable containers
  ```yaml
  # Containerspec
  securityContext:
    readOnlyRootFilesystem: true
  ```
  - see: https://lucasvanlierop.nl/blog/2017/12/31/truly-immutable-deployments-with-docker-or-kubernetes/
- Other security features
  - https://kubernetes.io/docs/tasks/configure-pod-container/security-context/
  - https://kubernetes.io/docs/concepts/policy/pod-security-policy/
  - https://cloud.google.com/architecture/best-practices-for-operating-containers


## Additional

- Add values.schema.json
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
- InitContainer:
   - use `drush twigc` in an init container, copy to proper location of the containers.
- HA: is it an option to use something like "at least 1 pod on each node"?
- Consider RBAC
  - https://helm.sh/docs/chart_best_practices/rbac/#yaml-configuration

# Research
- https://github.com/roboll/helmfile
- https://github.com/zegl/kube-score
- https://github.com/derailed/popeye
- https://kubernetes.io/blog/2019/07/18/api-deprecations-in-1-16/
- https://github.com/fairwindsops/nova

## Not necessarily Helm
- https://github.com/cloudquery/cloudquery
- https://github.com/armosec/kubescape
