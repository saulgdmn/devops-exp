
### General
An experimental project for training DevOps practices.

### Application
- Python application consists from two parts:
    - a producer which connects to the Kafka broker and sends random generated data to the topic;
    - a consumer which connects to the Kafka broker, consumes data and sends it to a MongoDB collection.
- Each part of application is running into docker container on the EC2 instance.
- Zookeeper, Apache Kafka and MongoDB with metrics exporters deployed on the DigitalOcean droplet.
- Docker compose is used for configuring, building and running services. 

### Monitoring

- Prometheus & Grafana are running on another EC2 instance.
- Prometheus has configured scrape configs of exporters.
- Grafana has provisioned datasources (Prometheus) and dashboards (System, Kafka, MongoDB).

### Configuration and infrastructure
- Terraform is used for creating and destroying infrastracture in the AWS and DigitalOcean;
- Ansible is used for configuring servers via roles:
    - installing docker;
    - deploying mongo & kafka stack;
    - deploying monitoring stack;
    - deploying application.

### Cloud providers
- AWS is used for running instances within Free Tier.
- DigitalOcean is used for creating droplet with higher performance and larger resources within student credits bonuses.
 