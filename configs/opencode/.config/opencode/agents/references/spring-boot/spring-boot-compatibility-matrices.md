# Spring Boot Compatibility Matrices

## Spring for Apache Kafka (spring-kafka) and Kafka Client 
Spring for Apache Kafka is based on the pure java `kafka-clients` jar.

| Spring for Apache Kafka Version | Spring Integration for Apache Kafka Version | `kafka-clients` | Spring Boot Version |
|---------------------------------|---------------------------------------------|-----------------|---------------------|
| 3.3.x                           | 6.4.x                                       | 3.8.0 to 3.9.0  | 3.4.x               |
| 3.2.x                           | 6.3.x                                       | 3.7.0           | 3.3.x               |
| 3.1.x                           | 6.2.x                                       | 3.6.0           | 3.2.x               |
| 3.0.x                           | ~~6.0.x~~ /6.1.x                            | 3.3.2 to 3.6.0  | ~~3.0.x~~ /3.1.x    |

### Overriding a Kafka client

Set `kafka.version` property if a different version of `kafka-clients` or `kafka-streams` is needed.
Set `spring-kafka.version` property to use a different Spring for Apache Kafka version with a supported Spring Boot version
```xml
<properties>
    <kafka.version>4.0.0</kafka.version>
    <spring-kafka.version>4.0.5</spring-kafka.version>
</properties>
```

## Spring Cloud Release Train

Table 1. Release train Spring Boot compatibility (see [here](https://github.com/spring-cloud/spring-cloud-release/wiki/Supported-Versions#supported-releases) for more detailed information).

| Spring Cloud Version       | Spring Boot Version                   | End of life |
|----------------------------|---------------------------------------|-------------|
| `2025.1.x` aka Oakwood     | 4.0.x                                 | false       |
| `2025.0.x` aka Northfields | 3.5.x                                 | false       |
| `2024.0.x` aka Moorgate    | 3.4.x                                 | true        |
| `2023.0.x` aka Leyton      | 3.3.x, 3.2.x                          | true        |
| `2022.0.x` aka Kilburn     | 3.0.x, 3.1.x (Starting with 2022.0.3) | true        |
| `2021.0.x` aka Jubilee     | 2.6.x, 2.7.x (Starting with 2021.0.3) | true        |

| Dependency project                                                                            | *2025.1 (Oakwood)* | 2025.0 (Northfields) | ~~2024.0 (Moorgate)~~ | ~~2023.0 (Leyton)~~ | ~~2022.0 (Kilburn)~~ |
|-----------------------------------------------------------------------------------------------|--------------------|----------------------|-----------------------|---------------------|----------------------|
| [spring-boot](https://spring.io/projects/spring-boot#support)                                 | *4.0.x*            | 3.5.x                | 3.4.x                 | 3.3.x/3.2.x         | 3.1.x/3.0.x          |
| [spring-cloud-bus](https://spring.io/projects/spring-cloud-bus#support)                       | *5.0.x*            | 4.3.x                | 4.2.x                 | 4.1.x               | 4.0.x                |
| [spring-cloud-circuitbreaker](https://spring.io/projects/spring-cloud-circuitbreaker#support) | *5.0.x*            | 3.3.x                | 3.2.x                 | 3.1.x               | 3.0.x                |
| [spring-cloud-commons](https://spring.io/projects/spring-cloud-commons#support)               | *5.0.x*            | 4.3.x                | 4.2.x                 | 4.1.x               | 4.0.x                |
| [spring-cloud-config](https://spring.io/projects/spring-cloud-config#support)                 | *5.0.x*            | 4.3.x                | 4.2.x                 | 4.1.x               | 4.0.x                |
| [spring-cloud-consul](https://spring.io/projects/spring-cloud-consul#support)                 | *5.0.x*            | 4.3.x                | 4.2.x                 | 4.1.x               | 4.0.x                |
| [spring-cloud-contract](https://spring.io/projects/spring-cloud-contract#support)             | *5.0.x*            | 4.3.x                | 4.2.x                 | 4.1.x               | 4.0.x                |
| [spring-cloud-function](https://spring.io/projects/spring-cloud-function#support)             | *5.0.x*            | 4.3.x                | 4.2.x                 | 4.1.x               | 4.0.x                |
| [spring-cloud-gateway](https://spring.io/projects/spring-cloud-gateway#support)               | *5.0.x*            | 4.3.x                | 4.2.x                 | 4.1.x               | 4.0.x                |
| [spring-cloud-kubernetes](https://spring.io/projects/spring-cloud-kubernetes#support)         | *5.0.x*            | 3.3.x                | 3.2.x                 | 3.1.x               | 3.0.x                |
| [spring-cloud-netflix](https://spring.io/projects/spring-cloud-netflix#support)               | *5.0.x*            | 4.3.x                | 4.2.x                 | 4.1.x               | 4.0.x                |
| [spring-cloud-openfeign](https://spring.io/projects/spring-cloud-openfeign#support)           | *5.0.x*            | 4.3.x                | 4.2.x                 | 4.1.x               | 4.0.x                |
| [spring-cloud-stream](https://spring.io/projects/spring-cloud-stream#support)                 | *5.0.x*            | 4.3.x                | 4.2.x                 | 4.1.x               | 4.0.x                |
| [spring-cloud-task](https://spring.io/projects/spring-cloud-task#support)                     | *5.0.x*            | 3.3.x                | 3.2.x                 | 3.1.x               | 3.0.x                |
| [spring-cloud-vault](https://spring.io/projects/spring-cloud-vault#support)                   | *5.0.x*            | 4.3.x                | 4.2.x                 | 4.1.x               | 4.0.x                |
| [spring-cloud-zookeeper](https://spring.io/projects/spring-cloud-zookeeper#support)           | *5.0.x*            | 4.3.x                | 4.2.x                 | 4.1.x               | 4.0.x                |