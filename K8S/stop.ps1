kubectl delete `
    -f rabbitmq.yaml `
    -f pubsub-rabbitmq.yaml `
    -f platforms-service.yaml `
    -f commands-service.yaml `
    -f commands-depl.yaml `
    -f platforms-depl.yaml