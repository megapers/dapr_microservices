kubectl apply `
    -f rabbitmq.yaml `
    -f pubsub-rabbitmq.yaml `
    -f platforms-np-srv.yaml `
    -f platforms-service.yaml `
    -f commands-service.yaml `
    -f commands-depl.yaml `
    -f platforms-depl.yaml 
