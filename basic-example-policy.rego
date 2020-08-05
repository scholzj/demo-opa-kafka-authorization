package kafka.authz.example.basic

default allow = false

allow {
    not deny
}

deny {
    not allow_consumer_group
    not allow_producer_group
    not allow_admin_group
}

allow_consumer_group {
    is_consumer_operation
    is_consumer_group
}

allow_producer_group {
    is_producer_operation
    is_producer_group
}

allow_admin_group {
    is_admin_operation
    is_admin_group
}

###############################################################################
# Groups and their helper rules
###############################################################################

consumer_group = ["tom", "tyrone", "matt", "pepe", "douglas"]
producer_group = ["jack", "conor", "keinan", "john"]
admin_group = ["dean", "christian"]

is_consumer_group {
    consumer_group[_] == principal.name
}

is_producer_group {
    producer_group[_] == principal.name
}

is_admin_group {
    admin_group[_] == principal.name
}

###############################################################################
# Operations and their helper rules
###############################################################################

consumer_operations = {
                        "Topic": ["Read", "Describe"], 
                        "Group": ["Read", "Describe"]
                    }

producer_operations = {
                        "Topic": ["Write", "Describe"]
                    }

admin_operations = {
                    "Topic": ["Read", "Write", "Create", "Delete", "Alter", "Describe", "ClusterAction", "DescribeConfigs", "AlterConfigs"], 
                    "Group": ["Read", "Delete", "Describe"],
                    "Cluster": ["Create", "Alter", "Describe", "ClusterAction", "DescribeConfigs", "AlterConfigs"]
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
# Helper rules for input processing
###############################################################################

principal = {"fqn": parsed.CN, "name": cn_parts[0]} {
    parsed := parse_user(urlquery.decode(input.session.sanitizedUser))
    cn_parts := split(parsed.CN, ".")
}

parse_user(user) = {key: value |
    parts := split(user, ",")
    [key, value] := split(parts[_], "=")
}