# Helm charts

Opinionated helm charts for deploying Drupal in Kubernetes.

Note, that the chart does not provide a demo Drupal instance, users are expected to use their own, appropriately prepared images.

## Add repo

`helm repo add brainsum https://brainsum.github.io/helm`

## Install or upgrade

`helm upgrade <release name> brainsum/drupal --install --values <values file>`


## Note

This Chart has been tested with Kubernetes 1.21.

# Sources

- <https://github.com/marcel-dempers/docker-development-youtube-series/tree/master/kubernetes/helm>
- <https://helm.sh/docs/>
- <https://kubernetes.io/docs/home/>
- <https://github.com/doitintl/kube-no-trouble>
- <https://github.com/FairwindsOps/pluto>
