# Consul, Nomad and OPS services

This is a local setup, for demo purposes, of Consul and Nomad with current cloud services.

This is supposed to be used with my [systemd-nomad](https://github.com/diogok/systemd-nomad).

## Features

- [Consul]() for service discovery
- [Weave]() for service mesh
- [Nomad]() for orchestration
- [Elasticsearch]() for logs and metrics data
- [Fluentbit](), from fluentd, for logging gathering
- [Kibana]() for logging viewing
- [Curator]() for log rotation
- [Prometheus]() for metrics gathering
- [Grafana]() for metrics viewing
- Some ready grafana dashboards
- [Traefik]() for proxying
- [Jaeger]() for open tracing
- [Node exporter]() for machine metrics
- [Elasticsearch export]() for ES metrics

Runing elasticsearch (or any db) in the orchestrated cluster is not ideal and it is done here only for demonstration.

## Running

To install consul, nomad, levant (a tool to easier deploy to nomad) and weave:

```
make install
```

To start all in dev mode:

```
make start
```

To run all services:

```
make deploy-all
```

To run a single service:

make deploy JOB=services/service_name.nomad

## Acessing

Important links:

- Consul at [http://localhost:8500]
- Nomad at [http://localhost:4646]
- Weave at [http://localhost:4040]
- Traefik admin at  [http://localhost:8080]
- Grafana at [http://localhost/grafana]
- Jaeger at  [http://localhost/jaeger]

## License

MIT
