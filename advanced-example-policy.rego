package kafka.authz.example.crds

import data.kubernetes.kafkatopics
import data.kubernetes.kafkausers

default allow = false

allow {
    not deny
}

deny {
    not allow_consumer_topic
    not allow_consumer_group
    not allow_producer
    not allow_admin
}

allow_consumer_topic {
    is_topic_resource
    is_consumer_operation
    is_consumer_group
}

allow_consumer_group {
    is_group_resource
    is_consumer_operation
    startswith(group_name, principal.name)
}

allow_producer {
    is_topic_resource
    is_producer_operation
    is_producer_group
}

allow_admin {
    is_admin_operation
    is_admin_group
}

###############################################################################
# Helper rules for checking groups
###############################################################################

admin_groups := ["admin"]

is_consumer_group {
    user_groups(principal.name)[_] == topic_consumer_groups(topic_name)[_]
}

is_producer_group {
    user_groups(principal.name)[_] == topic_producer_groups(topic_name)[_]
}

is_admin_group {
    user_groups(principal.name)[_] == admin_groups[_]
}

user_groups(user) = groups {
    groups := json.unmarshal(kafkausers[_][user].metadata.annotations["groups"])
}

topic_consumer_groups(topic) = groups {
    groups := json.unmarshal(kafkatopics[_][topic].metadata.annotations["consumer-groups"])
}

topic_producer_groups(topic) = groups {
    groups := json.unmarshal(kafkatopics[_][topic].metadata.annotations["producer-groups"])
}

consumer_operations = {
                        "Topic": ["Read", "Describe"], 
                        "Group": ["Read", "Describe"]
                    }

producer_operations = {
                        "Topic": ["Write", "Describe"]
                    }

admin_operations = {
                    "Topic": ["Read", "Write", "Create", "Delete", "Alter", "Describe", "ClusterAction", "DescribeConfigs", "AlterConfigs"], 
                    "Group": ["Read", "Write", "Create", "Delete", "Alter", "Describe", "ClusterAction", "DescribeConfigs", "AlterConfigs"],
                    "Cluster": ["Read", "Write", "Create", "Delete", "Alter", "Describe", "ClusterAction", "DescribeConfigs", "AlterConfigs", "IdempotentWrite"]
                    }

is_consumer_operation {
    consumer_operations[input.resource.resourceType.name][_] == input.operation.name
}

is_producer_operation {
    producer_operations[input.resource.resourceType.name][_] == input.operation.name
}

is_admin_operation {
    admin_operations[input.resource.resourceType.name][_] == input.operation.name
}

###############################################################################
# Helper rules for input processing.
###############################################################################

is_topic_resource {
    input.resource.resourceType.name == "Topic"
}

topic_name = input.resource.name {
    is_topic_resource
}

is_group_resource {
    input.resource.resourceType.name == "Group"
}

group_name = input.resource.name {
    is_group_resource
}

principal = {"fqn": parsed.CN, "name": cn_parts[0]} {
    parsed := parse_user(urlquery.decode(input.session.sanitizedUser))
    cn_parts := split(parsed.CN, ".")
}

parse_user(user) = {key: value |
    parts := split(user, ",")
    [key, value] := split(parts[_], "=")
}