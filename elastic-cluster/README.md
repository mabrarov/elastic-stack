# Docker Compose project for Elastic cluster

Docker Compose project for Elastic cluster consisting of:

1. 3 master-eligible / data / ingesting Elasticsearch nodes.
1. 2 [coordinating only](https://www.elastic.co/guide/en/elasticsearch/reference/current/modules-node.html#coordinating-only-node) Elasticsearch nodes.
1. 2 Kibana instances.
1. HAProxy load balancer in front of Kibana instances.

```text
                      ┌─────────────────────────────┐
                      |                             |
                      │         Kibana user         │
                      |                             |
                      └──────────────┬──────────────┘
                                     │
                      ┌──────────────▼──────────────┐
                      │       kibana-balancer       │
                      |                             |
                      │          (HAProxy)          │
                      └──────────────┬──────────────┘
                                     │
                  ┌──────────────────▼──────────────────┐
                  │                                     │
   ┌──────────────▼──────────────┐       ┌──────────────▼──────────────┐
   │                             │       │                             │
   |           kibana1           |       |           kibana2           |
   │                             │       │                             │
   └──────────────┬──────────────┘       └──────────────┬──────────────┘
                  │                                     │
                  └──────────────────▼──────────────────┘
                                     │
┌────────────────────────────────────│────────────────────────────────────┐
|                                    |                                    |
|                 ┌──────────────────▼──────────────────┐                 |
│                 │                                     │                 │
│  ┌──────────────▼──────────────┐       ┌──────────────▼──────────────┐  │
│  │       elasticsearch4        │       │       elasticsearch5        │  │
│  │                             │       │                             │  │
│  │     (coordinating node)     │       │     (coordinating node)     │  │
│  └─────────────────────────────┘       └─────────────────────────────┘  │
│                     ┌─────────────────────────────┐                     │
│                     │       elasticsearch1        │                     │
│                     |                             |                     │
│                     │ (master-eligible data node) │                     │
│                     └─────────────────────────────┘                     │
│                     ┌─────────────────────────────┐                     │
│                     │       elasticsearch2        │                     │
│                     │                             │                     │
│                     │ (master-eligible data node) │                     │
│                     └─────────────────────────────┘                     │
│                     ┌─────────────────────────────┐                     │
│                     │       elasticsearch3        │                     │
│                     |                             |                     │
│                     │ (master-eligible data node) │                     │
│                     └─────────────────────────────┘                     │
│                                                                         │
│                          Elasticsearch cluster                          │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

Useful commands for [Kibana Dev Tools](http://localhost/app/dev_tools#/console):

```text
GET _cat/nodes?v
GET _cat/indices?v
GET _cat/shards?v&index=fluent-bit-*&s=index
GET fluent-bit

DELETE fluent-bit-000001
DELETE fluent-bit-*

PUT /fluent-bit-000001
{
  "aliases": {
    "fluent-bit": {}
  },
  "mappings": {
    "properties": {
      "@timestamp": {
        "type": "date"
      },
      "message": {
        "type": "text",
        "fields": {
          "keyword": {
            "type": "text"
          }
        }
      }
    }
  },
  "settings": {
    "index": {
      "number_of_shards": 2,
      "number_of_replicas": 1,
      "refresh_interval": "30s"
    }
  }
}

PUT /fluent-bit-000002
{
  "mappings": {
    "properties": {
      "@timestamp": {
        "type": "date"
      },
      "message": {
        "type": "text",
        "fields": {
          "keyword": {
            "type": "text"
          }
        }
      }
    }
  },
  "settings": {
    "index": {
      "number_of_shards": 2,
      "number_of_replicas": 1,
      "refresh_interval": "30s"
    }
  }
}

PUT /fluent-bit-000003
{
  "mappings": {
    "properties": {
      "@timestamp": {
        "type": "date"
      },
      "message": {
        "type": "text",
        "fields": {
          "keyword": {
            "type": "text"
          }
        }
      }
    }
  },
  "settings": {
    "index": {
      "number_of_shards": 2,
      "number_of_replicas": 1,
      "refresh_interval": "30s"
    }
  }
}

PUT /fluent-bit-000004
{
  "mappings": {
    "properties": {
      "@timestamp": {
        "type": "date"
      },
      "message": {
        "type": "text",
        "fields": {
          "keyword": {
            "type": "text"
          }
        }
      }
    }
  },
  "settings": {
    "index": {
      "number_of_shards": 2,
      "number_of_replicas": 1,
      "refresh_interval": "30s"
    }
  }
}
```
