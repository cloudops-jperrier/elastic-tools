namespace=<INDEX_NAMESPACE>;
for template in $(curl -nks  "https://<ELASTIC_URL>:<ELASTIC_PORT>/_cat/templates?h=name" | egrep -i "logs-\w+\.\w+$") ;
do
 echo $template;
 curl -nks  "https://<ELASTIC_URL>:<ELASTIC_PORT>/_index_template/$template" |

 jq ".index_templates[].index_template | .index_patterns = [\"$template-$namespace*\"] | .priority = 250 | .composed_of += [\"logs-$namespace@custom\"] | del(.template.settings.index.lifecycle)" |

 curl -nks -XPUT "https://<ELASTIC_URL>:<ELASTIC_PORT>/_index_template/$template-$namespace"  -H 'Content-Type: application/json' -d @-

  done
