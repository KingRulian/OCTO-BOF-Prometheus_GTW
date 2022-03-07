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
- [x] Creation des secrets TLS
  - [x] 1 qui est expire 
  - [x] 1 qui expire (<30 jours)
  - [x] 1 qui expire dans longtemps
- [ ] Creation du cronjob