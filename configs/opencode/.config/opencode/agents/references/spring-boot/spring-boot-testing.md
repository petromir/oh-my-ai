# Spring Boot testing rules

## Kafka
Always use the embedded Kafka broker in tests by adding this dependency:

**Maven:**
```xml
<dependency>
    <groupId>org.springframework.kafka</groupId>
    <artifactId>spring-kafka-test</artifactId>
    <scope>test</scope>
</dependency>
```

**Gradle:**
```groovy
testImplementation 'org.springframework.kafka:spring-kafka-test'
```

