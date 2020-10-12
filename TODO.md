# To-dos

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

# Research
- https://github.com/roboll/helmfile
