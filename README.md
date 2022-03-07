# OCTO-BOF-Prometheus_GTW#

## Use Case

Verification des secrets de type TLS et verification de leur date d'expiration a 30 jours.
C'est une tache cronjob qui lancera notre script.  

## TODO

- [ ] Setup Environnement
  - [ ] KinD
  - [ ] Prom GTW
  - [ ] Prometheus
  - [ ] Grafana
- [ ] Creation des secrets TLS
  - [ ] 3 qui expirent (5, 10, 15 jours)
  - [ ] 3 qui expirent dans 3 ans
- [ ] Creation du cronjob