#!/bin/bash

# Simple script to create new templates and add index lifecycle policies to datastreams by including composite templates.
# This requires you have the composite template created prior to running this.
# Based on https://github.com/bmorelli25/observability-docs/blob/7abaf577503a0756cd5137a55963a32ab278240c/docs/en/ingest-management/data-streams.asciidoc

namespace=<INDEX_NAMESPACE>;
index_type=logs;

for template in $(curl -nks  "https://<ELASTIC_URL>:<ELASTIC_PORT>/_cat/templates?h=name" | egrep -i "$index_type-\w+\.\w+$") ;
do
  echo $template;
  curl -nks  "https://<ELASTIC_URL>:<ELASTIC_PORT>/_index_template/$template" |

  jq ".index_templates[].index_template | .index_patterns = [\"$template-$namespace*\"] | .priority = 250 | .composed_of += [\"$index_type-$namespace@custom\"] | del(.template.settings.index.lifecycle)" |

  curl -nks -XPUT "https://<ELASTIC_URL>:<ELASTIC_PORT>/_index_template/$template-$namespace"  -H 'Content-Type: application/json' -d @-

done
