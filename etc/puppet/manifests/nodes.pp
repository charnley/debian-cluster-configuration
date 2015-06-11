
node 'jck-test' {
    include node_setup
}

node /^node\d+$/ {
    include node_setup
}

node /^spasnode\d+$/ {
    include node_setup
}

node /^thinnode\d+$/ {
    include node_setup
}

