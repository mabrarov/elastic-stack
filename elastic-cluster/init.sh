#!/bin/bash

set -e

DOCKER_HOST='localhost'

elasticsearch_api_user='elastic'
elasticsearch_api_password='elastic'
elasticsearch_api_url_base="http://${DOCKER_HOST}:9201"
kibana_api_url_base="http://${DOCKER_HOST}:5601"
elasticsearch_index_alias="fluent-bit"
elasticsearch_index_name="${elasticsearch_index_alias}-000001"
kibana_index_pattern_id="${elasticsearch_index_alias}"
kibana_index_pattern_title="${elasticsearch_index_alias}-*"

response_status_code="$(curl -ks -X POST \
  -o /dev/null -w '%{http_code}\n' \
  --user "${elasticsearch_api_user}:${elasticsearch_api_password}" \
  "${elasticsearch_api_url_base}/_license/start_trial?acknowledge=true")"
if [[ "${response_status_code}" -ne 200 ]]; then
  echo "Failed to apply Elasticsearch trial license" >&2
  exit 1
else
  echo "Successfully applied Elasticsearch trial license"
fi

response_status_code="$(curl -s -X PUT \
  -o /dev/null -w '%{http_code}\n' \
  --user "${elasticsearch_api_user}:${elasticsearch_api_password}" \
  -H 'Content-Type: application/json' \
  -d \
"{
  \"aliases\": {
    \"${elasticsearch_index_alias}\": {}
  },
  \"mappings\": {
    \"properties\": {
      \"@timestamp\": {
        \"type\": \"date\"
      },
      \"message\": {
        \"type\": \"text\",
        \"fields\": {
          \"keyword\": {
            \"type\": \"text\"
          }
        }
      }
    }
  },
  \"settings\": {
    \"index\": {
      \"number_of_shards\": 2,
      \"number_of_replicas\": 1,
      \"refresh_interval\": \"30s\"
    }
  }
}
" \
  "${elasticsearch_api_url_base}/${elasticsearch_index_name}")"
if [[ "${response_status_code}" -ne 200 ]]; then
  echo "Failed to create ${elasticsearch_index_name} Elasticsearch index" >&2
  exit 1
else
  echo "Successfully created ${elasticsearch_index_name} Elasticsearch index with ${elasticsearch_index_alias} alias"
fi

response_status_code="$(curl -s -X POST \
  -o /dev/null -w '%{http_code}\n' \
  --user "${elasticsearch_api_user}:${elasticsearch_api_password}" \
  -H 'kbn-xsrf: required_header' \
  -H 'Content-Type: application/json' \
  -d \
"{
  \"attributes\": {
    \"title\": \"${kibana_index_pattern_title}\",
    \"timeFieldName\": \"@timestamp\",
    \"fields\": \"[ { \\\"name\\\": \\\"@timestamp\\\", \\\"type\\\": \\\"date\\\", \\\"esTypes\\\": [ \\\"date\\\" ], \\\"searchable\\\": true, \\\"aggregatable\\\": true, \\\"readFromDocValues\\\": true, \\\"metadata_field\\\": false }, { \\\"name\\\": \\\"_id\\\", \\\"type\\\": \\\"string\\\", \\\"esTypes\\\": [ \\\"_id\\\" ], \\\"searchable\\\": true, \\\"aggregatable\\\": true, \\\"readFromDocValues\\\": false, \\\"metadata_field\\\": true }, { \\\"name\\\": \\\"_index\\\", \\\"type\\\": \\\"string\\\", \\\"esTypes\\\": [ \\\"_index\\\" ], \\\"searchable\\\": true, \\\"aggregatable\\\": true, \\\"readFromDocValues\\\": false, \\\"metadata_field\\\": true }, { \\\"name\\\": \\\"_score\\\", \\\"type\\\": \\\"number\\\", \\\"searchable\\\": false, \\\"aggregatable\\\": false, \\\"readFromDocValues\\\": false, \\\"metadata_field\\\": true }, { \\\"name\\\": \\\"_source\\\", \\\"type\\\": \\\"_source\\\", \\\"esTypes\\\": [ \\\"_source\\\" ], \\\"searchable\\\": false, \\\"aggregatable\\\": false, \\\"readFromDocValues\\\": false, \\\"metadata_field\\\": true }, { \\\"name\\\": \\\"_type\\\", \\\"type\\\": \\\"string\\\", \\\"esTypes\\\": [ \\\"_type\\\" ], \\\"searchable\\\": true, \\\"aggregatable\\\": true, \\\"readFromDocValues\\\": false, \\\"metadata_field\\\": true }, { \\\"name\\\": \\\"message\\\", \\\"type\\\": \\\"string\\\", \\\"esTypes\\\": [ \\\"text\\\" ], \\\"searchable\\\": true, \\\"aggregatable\\\": false, \\\"readFromDocValues\\\": false, \\\"metadata_field\\\": false }, { \\\"name\\\": \\\"message.keyword\\\", \\\"type\\\": \\\"string\\\", \\\"esTypes\\\": [ \\\"text\\\" ], \\\"searchable\\\": true, \\\"aggregatable\\\": false, \\\"readFromDocValues\\\": false, \\\"metadata_field\\\": false, \\\"subType\\\": { \\\"multi\\\": { \\\"parent\\\": \\\"message\\\" } } } ]\"
  }
}
" \
  "${kibana_api_url_base}/api/saved_objects/index-pattern/${kibana_index_pattern_id}")"
if [[ "${response_status_code}" -ne 200 ]]; then
  echo "Failed to create ${kibana_index_pattern_id} Kibana index pattern" >&2
  exit 1
else
  echo "Successfully created ${kibana_index_pattern_id} Kibana index pattern with ${kibana_index_pattern_title} title"
fi

echo "Try login with ${elasticsearch_api_user}/${elasticsearch_api_password} credentials to Kibana located at ${kibana_api_url_base}"
