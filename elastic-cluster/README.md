# Docker Compose project for Elastic cluster

Docker Compose project for Elastic cluster consisting of:

1. 3 master / data / ingesting Elasticsearch nodes.
1. 1 coordinating Elasticsearch node.
1. 1 Kibana node

Useful commands for [Kibana Dev Tools](http://localhost:5601/app/dev_tools#/console):

```text
GET _cat/nodes?v
GET _cat/indices?v
GET _cat/shards?v&index=fluent-bit-*
```
