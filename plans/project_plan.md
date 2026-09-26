# E-Commerce Interview Project — DDD + Monorepo + gRPC + Kafka + Redis + Cassandra + AI/RAG + Kubernetes

## 1. Project Goal

Build a production-style e-commerce platform specifically for backend/system-design interview preparation.

The project will use:

- Java 21+
- Spring Boot
- Domain-Driven Design (DDD)
- A **single monorepo**
- **Multiple independently deployable services**
- gRPC for synchronous service-to-service communication
- Kafka for asynchronous communication and domain events
- PostgreSQL + Hibernate/JPA for transactional data
- Redis Cluster for caching, distributed rate limiting, and selected coordination
- Cassandra for horizontally scalable, high-volume workloads
- AI + RAG for natural-language product discovery
- Docker
- Kubernetes
- Helm
- Prometheus + Grafana
- OpenTelemetry
- Testcontainers
- JUnit / Mockito / REST Assured / ArchUnit

The target is not to recreate Amazon.

The target is to build a **small but deep distributed system** where you can explain:

- Domain boundaries
- Aggregates
- Service ownership
- gRPC contracts
- Kafka events
- Consistency
- Failure handling
- Idempotency
- Caching
- Horizontal scaling
- Cassandra data modeling
- Kubernetes deployment
- AI/RAG architecture
- Observability
- Trade-offs

---

# 2. Core Architecture Decision

Use:

> **Monorepo + multiple services + DDD bounded contexts + gRPC for synchronous communication + Kafka for asynchronous communication.**

The repository is unified, but the runtime is distributed.

```text
                         ┌──────────────────────┐
                         │      Web / UI        │
                         │   React / Next.js    │
                         └──────────┬───────────┘
                                    │
                               HTTPS / REST
                                    │
                         ┌──────────▼───────────┐
                         │      API Gateway     │
                         │ Auth / Rate Limiting │
                         │ Routing / Security   │
                         └──────────┬────────────┘
                                    │
          ┌─────────────────────────┼─────────────────────────┐
          │                         │                         │
          ▼                         ▼                         ▼
   Product Service            Order Service             Customer Service
          │                         │                         │
          │                         │                         │
          ▼                         │                         ▼
     PostgreSQL                    │                    PostgreSQL
                                   │
                            gRPC │
                                   ▼
                           Inventory Service
                                   │
                                   ▼
                              PostgreSQL

                    ┌────────────────────────────┐
                    │            Redis            │
                    │       Redis Cluster         │
                    │ Cache / Rate Limiting       │
                    └────────────────────────────┘

                    ┌────────────────────────────┐
                    │            Kafka            │
                    │   Domain / Integration     │
                    │           Events           │
                    └─────────────┬──────────────┘
                                  │
             ┌────────────────────┼────────────────────┐
             ▼                    ▼                    ▼
        Payment Service    Notification Service   Analytics Service
             │                                         │
             ▼                                         ▼
        PostgreSQL                                  Cassandra
                                                    Cluster

                    ┌────────────────────────────┐
                    │       Search Service        │
                    │ Structured + Semantic Search│
                    └─────────────┬──────────────┘
                                  │
                                  ▼
                            Vector Store

                    ┌────────────────────────────┐
                    │         AI Service         │
                    │     RAG Product Assistant  │
                    └────────────────────────────┘

                    ┌────────────────────────────┐
                    │        Kubernetes          │
                    │       + Helm + HPA         │
                    └────────────────────────────┘
```

---

# 3. Monorepo Strategy

The repository contains all services and shared contracts.

The services remain independently buildable and deployable.

Recommended top-level structure:

```text
ecommerce-platform/
│
├── services/
│   ├── api-gateway/
│   ├── identity-service/
│   ├── customer-service/
│   ├── product-service/
│   ├── cart-service/
│   ├── order-service/
│   ├── inventory-service/
│   ├── payment-service/
│   ├── fulfillment-service/
│   ├── notification-service/
│   ├── search-service/
│   ├── analytics-service/
│   └── ai-service/
│
├── proto/
│   ├── customer/
│   │   └── customer.proto
│   ├── product/
│   │   └── product.proto
│   ├── inventory/
│   │   └── inventory.proto
│   ├── payment/
│   │   └── payment.proto
│   ├── fulfillment/
│   │   └── fulfillment.proto
│   └── search/
│       └── search.proto
│
├── libraries/
│   ├── common-events/
│   ├── common-security/
│   └── common-observability/
│
├── infrastructure/
│   ├── docker/
│   ├── postgres/
│   ├── redis/
│   ├── kafka/
│   └── cassandra/
│
├── helm/
│   └── ecommerce/
│
├── docs/
│   ├── architecture/
│   ├── adr/
│   ├── api/
│   └── diagrams/
│
├── pom.xml
├── docker-compose.yml
└── README.md
```

The root build should orchestrate all modules while allowing an individual service to be built independently.

Example:

```text
./mvnw clean install

./mvnw -pl services/order-service test

./mvnw -pl services/inventory-service spring-boot:run
```

---

# 4. DDD Bounded Contexts → Services

Services should correspond to meaningful business boundaries.

| Bounded Context      | Service              |
| -------------------- | -------------------- |
| Identity & Access    | identity-service     |
| Customer             | customer-service     |
| Product Catalog      | product-service      |
| Shopping Cart        | cart-service         |
| Order Management     | order-service        |
| Inventory            | inventory-service    |
| Payment              | payment-service      |
| Fulfillment          | fulfillment-service  |
| Notification         | notification-service |
| Product Discovery    | search-service       |
| Analytics            | analytics-service    |
| AI Product Assistant | ai-service           |

Do not create services merely to increase the service count.

A bounded context should become a service when there is a meaningful boundary, ownership model, or scaling/deployment reason.

---

# 5. Service Ownership

Each service owns its own data.

```text
product-service
    └── product database

order-service
    └── order database

inventory-service
    └── inventory database

payment-service
    └── payment database

customer-service
    └── customer database
```

Never allow:

```text
Order Service
    ↓
direct SQL
    ↓
Inventory Service database
```

Instead:

```text
Order Service
    │
    └── gRPC
          ↓
    Inventory Service
```

This is an important distributed-systems boundary.

---

# 6. Service Communication Strategy

Use two communication mechanisms intentionally.

## Synchronous — gRPC

Use gRPC when the caller needs an immediate response.

Examples:

```text
Order → Inventory
Order → Customer
Order → Payment
Search → Product
AI → Search
```

Example:

```text
Order Service
      │
      │ ReserveInventory()
      ▼
Inventory Service
      │
      │ InventoryReservationResponse
      ▼
Order Service
```

## Asynchronous — Kafka

Use Kafka when the operation can continue asynchronously.

Examples:

```text
OrderCreated
PaymentCompleted
InventoryReserved
ProductUpdated
ProductViewed
OrderDelivered
```

Example:

```text
Order Service
      │
      │ OrderCreated
      ▼
    Kafka
      │
 ┌────┼───────────────┐
 ▼    ▼               ▼
Analytics Notification Search
```

### Guideline

> gRPC = "I need an answer now."

> Kafka = "Something happened; interested consumers can react."

---

# 7. gRPC Contract Design

Keep `.proto` files in the monorepo.

Example:

```text
proto/
├── inventory/
│   └── inventory.proto
├── payment/
│   └── payment.proto
├── customer/
│   └── customer.proto
└── search/
    └── search.proto
```

Example:

```proto
syntax = "proto3";

package inventory.v1;

service InventoryService {
  rpc ReserveInventory(ReserveInventoryRequest)
      returns (ReserveInventoryResponse);

  rpc ReleaseInventory(ReleaseInventoryRequest)
      returns (ReleaseInventoryResponse);

  rpc GetInventory(GetInventoryRequest)
      returns (GetInventoryResponse);
}
```

Use versioned packages:

```text
inventory.v1
inventory.v2
```

Avoid breaking existing contracts.

---

# 8. gRPC Production Concerns

Do not stop at "I used gRPC."

Implement and understand:

- Deadlines
- Timeouts
- Retries
- Idempotency
- gRPC status codes
- Metadata
- Authentication
- Interceptors
- Health checking
- Load balancing
- Connection management
- Error propagation
- OpenTelemetry tracing

Important rule:

> Do not blindly retry every gRPC request.

For example:

```text
ReserveInventory()
```

must be designed to tolerate retries safely.

Use an idempotency key:

```text
reservation_id
```

so:

```text
Retry #1 → reservation created
Retry #2 → existing reservation returned
```

---

# 9. DDD Package Structure Inside Each Service

Example:

```text
services/order-service/
│
├── src/main/java/com/example/order/
│
├── domain/
│   ├── model/
│   │   ├── Order.java
│   │   ├── OrderItem.java
│   │   ├── OrderStatus.java
│   │   └── Money.java
│   │
│   ├── event/
│   │   ├── OrderCreated.java
│   │   └── OrderCancelled.java
│   │
│   ├── repository/
│   │   └── OrderRepository.java
│   │
│   └── service/
│
├── application/
│   ├── command/
│   ├── query/
│   ├── handler/
│   └── dto/
│
├── infrastructure/
│   ├── persistence/
│   ├── grpc/
│   ├── messaging/
│   └── configuration/
│
└── interfaces/
    └── rest/
```

Dependency direction:

```text
REST / gRPC adapters
        ↓
Application
        ↓
Domain
        ↑
Infrastructure
```

The domain must not directly depend on:

- Spring
- Kafka
- Redis
- PostgreSQL
- gRPC implementation details

Infrastructure implements domain/application interfaces.

---

# 10. Main Domain Model

## Product

Aggregate:

```text
Product
 ├── ProductId
 ├── SKU
 ├── Name
 ├── Description
 ├── Money
 ├── Category
 └── ProductAttributes
```

## Cart

Aggregate:

```text
Cart
 ├── CartId
 ├── CustomerId
 └── CartItems
```

Cart owns its items.

When checkout begins, refresh product prices and calculate the checkout total using current catalog prices; cart prices are not locked. Browsing remains anonymous, but adding items to a cart and checking out require authentication. Associate authenticated activity with the user's ID. Guest users are not supported initially; create a short cookie-based guest identity extension plan before implementing that future capability.

## Order

Aggregate:

```text
Order
 ├── OrderId
 ├── CustomerId
 ├── OrderItems
 ├── Money
 ├── DeliveryDestinationId
 └── OrderStatus
```

Use a synthetic, non-identifying destination ID for the planned mock delivery workflow. Do not persist a real shipping address or other direct PII.

The order records checkout-refreshed item prices and total. If a refreshed total differs from what the shopper last saw, display the new total and require explicit customer confirmation before order submission.

## Inventory

Aggregate:

```text
InventoryItem
 ├── SKU
 ├── TotalStock
 ├── ReservedStock
 └── AvailableStock
```

Invariant:

```text
AvailableStock >= 0
```

Inventory reservation is all-or-nothing. Use one configurable timeout for every product, with an initial value of 15 minutes.

## Payment

Aggregate:

```text
Payment
 ├── PaymentId
 ├── OrderId
 ├── Amount
 └── PaymentStatus
```

---

# 11. Database Strategy

Use polyglot persistence deliberately.

| Workload                   | Technology         |
| -------------------------- | ------------------ |
| Users                      | PostgreSQL         |
| Products                   | PostgreSQL         |
| Orders                     | PostgreSQL         |
| Payments                   | PostgreSQL         |
| Inventory                  | PostgreSQL         |
| Cart                       | PostgreSQL / Redis |
| Product cache              | Redis              |
| Rate limiting              | Redis              |
| Activity events            | Cassandra          |
| Semantic product retrieval | Vector DB          |
| Event streaming            | Kafka              |

Do not use Cassandra simply because it is part of the technology stack.

---

# 12. Redis Architecture

Redis must be horizontally scalable.

Target:

```text
                 Application Pods
                       │
                       ▼
              Redis Cluster Client
                       │
       ┌───────────────┼────────────────┐
       ▼               ▼                ▼
   Primary 1       Primary 2        Primary 3
       │               │                │
       ▼               ▼                ▼
   Replica 1       Replica 2        Replica 3
```

Use Redis Cluster.

Important concepts:

- Hash slots
- Sharding
- Replication
- Failover
- Cluster-aware clients
- TTL
- Eviction policies

Use Redis for:

### Product cache

```text
product:{id}
```

### Category cache

```text
category:{id}
```

### Search result cache

```text
search:{hash}
```

### Rate limiting

```text
rate-limit:{userId}
rate-limit:{ip}
rate-limit:ai:{userId}
```

### Short-lived coordination

Use distributed locks only when there is a clear requirement.

Redis should not become the source of truth for:

- Orders
- Payments
- Inventory
- Customer accounts

---

# 13. Cassandra Architecture

Cassandra should be deployed as a multi-node cluster.

```text
                Cassandra Cluster
        ┌────────────┬────────────┐
        ▼            ▼            ▼
      Node 1       Node 2       Node 3
        │            │            │
        └────────────┼────────────┘
                     │
               Replication
                     │
        ┌────────────┬────────────┐
        ▼            ▼            ▼
      Node 4       Node 5       Node 6
```

Use Cassandra for:

- Product views
- Search events
- User activity
- Analytics events
- High-volume time-series-like access patterns

Example:

```sql
CREATE TABLE product_events (
    product_id uuid,
    event_date date,
    event_time timestamp,
    user_id uuid,
    event_type text,
    metadata text,
    PRIMARY KEY ((product_id, event_date), event_time, user_id)
);
```

The schema must be derived from queries.

Study:

- Partition key
- Clustering key
- Replication factor
- Consistency level
- Compaction
- Tombstones
- Hot partitions
- Read/write paths
- Horizontal scaling

---

# 14. Kafka Architecture

Topics:

```text
product-events
order-events
payment-events
inventory-events
fulfillment-events
customer-events
notification-events
analytics-events
```

Example:

```text
Order Service
     │
     │ OrderCreated
     ▼
   Kafka
     │
 ┌───┼──────────────────┐
 ▼   ▼                  ▼
Inventory Analytics Notification
```

Study:

- Partitions
- Consumer groups
- Offsets
- Consumer lag
- Ordering
- At-least-once delivery
- Retry topics
- Dead-letter topics
- Idempotent consumers
- Partition keys

---

# 15. Transactional Outbox

Implement the Outbox pattern in services that publish important events.

Without Outbox:

```text
DB transaction succeeds
        │
        ▼
Kafka publish fails
        │
        ▼
Inconsistent system
```

With Outbox:

```text
                DB Transaction
                     │
          ┌──────────┴──────────┐
          ▼                     ▼
   Business State          Outbox Event
          │                     │
          └──────────┬──────────┘
                     ▼
                 Commit
                     │
                     ▼
              Outbox Publisher
                     │
                     ▼
                   Kafka
```

This is a major interview topic.

---

# 16. Distributed Order Workflow

Keep the synchronous gRPC path small.

Example:

```text
Client
  │
  ▼
Order Service
  │
  │ gRPC
  ▼
Inventory Service
  │
  │ ReserveInventory()
  ▼
Reservation Response
  │
  ▼
Order Service
```

Then use Kafka for the longer workflow:

```text
OrderCreated
     │
     ▼
   Kafka
     │
     ▼
Payment Service
     │
     ▼
PaymentCompleted
     │
     ▼
   Kafka
     │
     ▼
Order Service
     │
     ▼
OrderConfirmed
```

If payment fails:

```text
PaymentFailed
      │
      ▼
Order Service
      │
      ▼
gRPC → Inventory Service
      │
      ▼
ReleaseInventory()
      │
      ▼
OrderCancelled
```

This combines:

- gRPC
- Kafka
- Saga
- Compensation
- Eventual consistency

---

# 17. Saga Pattern

Use a Saga for the order workflow.

Example:

```text
Create Order
     │
     ▼
Reserve Inventory
     │
     ├── Failure → Cancel Order
     │
     ▼
Process Payment
     │
     ├── Failure → Release Inventory
     │               ↓
     │          Cancel Order
     │
     ▼
Confirm Order
     │
     ▼
Fulfillment
```

Discuss:

- Choreography
- Orchestration
- Compensation
- Failure recovery
- Eventual consistency

For the project, start with simple orchestration around the Order domain and use Kafka for integration events.

---

# 18. Idempotency

Important gRPC operations and Kafka consumers must be idempotent.

Example:

```text
ReserveInventory(reservationId=123)
```

First request:

```text
reservation 123 created
```

Retry:

```text
reservation 123 already exists
→ return existing result
```

For Kafka:

```text
processed_events
----------------
event_id
consumer_name
processed_at
```

Use database constraints to prevent duplicate processing.

---

# 19. API Gateway

Use the gateway for:

- External authentication
- JWT validation
- Routing
- Rate limiting
- Request correlation ID
- API-level observability

External API:

```text
REST / HTTPS
```

Internal communication:

```text
gRPC
```

Avoid exposing internal gRPC services directly to the public internet.

---

# 20. Rate Limiting

Implement distributed rate limiting using Redis Cluster.

Example:

```text
Anonymous:
100 requests/minute

Authenticated:
500 requests/minute

AI:
20 requests/minute

Admin:
1000 requests/minute
```

Recommended algorithm:

**Token Bucket**

Flow:

```text
Request
   │
   ▼
API Gateway
   │
   ▼
Redis Cluster
   │
   ├── Allowed → service
   │
   └── Rejected → HTTP 429
```

Study:

- Fixed window
- Sliding window
- Token bucket
- Leaky bucket
- Distributed rate limiting

---

# 21. AI + RAG Product Assistant

Build a product assistant capable of queries such as:

```text
"Find me a laptop under ₹80,000 with 16GB RAM for programming."

"Which phones are good for photography?"

"Show me lightweight laptops suitable for developers."
```

Architecture:

```text
User Query
     │
     ▼
AI Service
     │
     ├── Query understanding
     │
     ├── Structured filters
     │
     └── Semantic query
             │
             ▼
        Search Service
             │
       ┌─────┴─────┐
       ▼           ▼
Structured      Vector
Filtering       Retrieval
       │           │
       └─────┬─────┘
             ▼
        Candidate Products
             │
             ▼
        AI Response
```

Use gRPC internally:

```text
AI Service
    │
    │ SearchProducts()
    ▼
Search Service
```

---

# 22. RAG Pipeline

Product update:

```text
Product Service
      │
      │ ProductUpdated
      ▼
    Kafka
      │
      ▼
Search / AI Pipeline
      │
      ▼
Embedding Generation
      │
      ▼
Vector Store
```

Query:

```text
Question
    │
    ▼
Embedding
    │
    ▼
Vector Retrieval
    │
    ▼
Structured Filters
    │
    ▼
Product Candidates
    │
    ▼
LLM
    │
    ▼
Grounded Answer
```

Use hybrid retrieval:

```text
Semantic Search
       +
Structured Filters
       +
Business Rules
```

The LLM should not invent product facts.

---

# 23. Kubernetes Architecture

Deploy each service independently.

```text
                         Ingress
                            │
                            ▼
                       API Gateway
                            │
       ┌────────────────────┼────────────────────┐
       ▼                    ▼                    ▼
 Product Pods           Order Pods         Customer Pods
       │                    │
       │                    │
       ▼                    ▼
 Product DB             Order DB

                     gRPC
                       │
                       ▼
                Inventory Pods

                     Kafka
                       │
       ┌───────────────┼───────────────┐
       ▼               ▼               ▼
   Payment       Notification      Analytics
                                      │
                                      ▼
                                  Cassandra
```

Use:

- Deployment
- Service
- ConfigMap
- Secret
- Ingress
- HPA
- Readiness probe
- Liveness probe
- Resource requests
- Resource limits

---

# 24. Horizontal Scaling Strategy

## Services

Services should be stateless wherever possible.

Example:

```text
order-service
     │
     ├── Pod 1
     ├── Pod 2
     ├── Pod 3
     └── Pod 4
```

Kubernetes Service distributes traffic.

## Redis

Scale through Redis Cluster shards.

```text
Primary 1 + Replica
Primary 2 + Replica
Primary 3 + Replica
```

## Kafka

Scale through partitions and consumer instances.

```text
Topic: order-events

Partition 0
Partition 1
Partition 2
Partition 3

Consumer Group
 ├── Consumer 1
 ├── Consumer 2
 ├── Consumer 3
 └── Consumer 4
```

## Cassandra

Scale by adding nodes.

```text
3 nodes → 6 nodes → 9 nodes
```

The interview objective is to explain how each layer scales differently.

---

# 25. Helm

Repository:

```text
helm/
└── ecommerce/
    ├── Chart.yaml
    ├── values.yaml
    ├── values-dev.yaml
    ├── values-prod.yaml
    └── templates/
        ├── deployments/
        ├── services/
        ├── ingress.yaml
        ├── configmaps/
        ├── secrets/
        └── hpa/
```

Make these configurable:

- Service replicas
- CPU
- Memory
- Environment
- Kafka settings
- Redis settings
- Database endpoints
- HPA thresholds

---

# 26. Observability

Architecture:

```text
Services
   │
   ├── Metrics ──► Prometheus ──► Grafana
   │
   ├── Logs ─────► OpenSearch
   │
   └── Traces ───► OpenTelemetry
```

Trace a request such as:

```text
HTTP Request
    │
    ▼
Gateway
    │
    ▼
Order Service
    │
    ├── gRPC → Inventory
    │
    └── Kafka → Payment
```

The trace should allow you to follow the request across services.

Monitor:

- API latency
- gRPC latency
- gRPC failures
- Kafka consumer lag
- Redis hit ratio
- Redis errors
- Cassandra latency
- Database connection pools
- JVM metrics
- Order processing latency
- AI latency
- Rate-limit violations

---

# 27. Testing Strategy

## Unit Tests

JUnit + Mockito.

Focus on domain logic:

```text
OrderTest
InventoryReservationTest
CartTest
MoneyTest
```

## Integration Tests

Use Testcontainers:

```text
PostgreSQL
Redis
Kafka
Cassandra
```

Example:

```text
Order Integration Test
       │
       ├── PostgreSQL
       ├── Kafka
       ├── Redis
       └── Inventory Service
```

## gRPC Tests

Test:

- Contract behavior
- Error codes
- Timeouts
- Retries
- Idempotency
- Invalid requests

## API Tests

Use REST Assured.

## Architecture Tests

Use ArchUnit.

Example:

```text
Order domain
   ❌ must not depend on Kafka infrastructure

Order domain
   ❌ must not depend on Redis

Order application
   ✓ may depend on domain abstractions
```

---

# 28. Development Phases

Target duration:

**20 weeks**

Available time:

- 1–2 hours/day
- Approximately 7–12 hours/week
- Limited AI assistance

The schedule deliberately leaves room for debugging and learning.

---

# Phase 0 — Domain Discovery & Architecture

## Week 1

### Build

- Business requirements
- Domain model
- Bounded contexts
- Context map
- Aggregates
- Entities
- Value objects
- Domain events
- Service boundaries
- Communication matrix

Create:

```text
docs/architecture/
docs/adr/
docs/diagrams/
```

### Important output

Create a service communication matrix:

| Caller  | Target    | Communication                    | Reason                       |
| ------- | --------- | -------------------------------- | ---------------------------- |
| Gateway | Services  | REST/gRPC                        | Request                      |
| Order   | Inventory | gRPC                             | Immediate reservation result |
| Order   | Customer  | gRPC                             | Customer validation/data     |
| AI      | Search    | gRPC                             | Search request               |
| Order   | Payment   | Kafka/gRPC depending on workflow | Payment workflow             |
| Product | Search    | Kafka                            | Product updates              |
| All     | Analytics | Kafka                            | Async analytics              |

---

# Phase 1 — Monorepo + Service Skeletons

## Week 2

Create:

```text
api-gateway
identity-service
customer-service
product-service
cart-service
order-service
inventory-service
payment-service
fulfillment-service
notification-service
search-service
analytics-service
ai-service
```

Each service should:

- Start independently
- Have its own Spring Boot configuration
- Have health endpoint
- Have logging
- Have basic test
- Have Dockerfile

Do not implement business functionality yet.

---

# Phase 2 — gRPC Foundation

## Week 3

Build:

```text
proto/
```

Add first contracts:

```text
customer.proto
product.proto
inventory.proto
```

Generate Java stubs.

Implement:

```text
Order Service
     │
     │ gRPC
     ▼
Inventory Service
```

Add:

- Deadlines
- Status codes
- Error handling
- Metadata
- Interceptors
- Request IDs

### Interview focus

Explain:

- REST vs gRPC
- HTTP/2
- Protocol Buffers
- Unary RPC
- Streaming awareness
- Deadlines
- Retry behavior

---

# Phase 3 — Product + Customer Services

## Weeks 4–5

Build Product Service:

- Product CRUD
- Categories
- SKU
- Pricing
- Attributes
- PostgreSQL
- Hibernate

Build Customer Service:

- Customer profile
- Addresses

Each service owns its own schema/database.

Do not share JPA entities across services.

---

# Phase 4 — Identity + Security

## Week 6

Implement:

- Registration
- Login
- JWT
- Refresh tokens
- Roles
- Gateway authentication
- Service-to-service authentication

Introduce gRPC metadata for internal identity propagation where appropriate.

Browsing the catalog does not require authentication. Adding items to a cart and checkout do. Assign an opaque user ID to authenticated users and use it for ownership and analytics. Do not require or persist direct PII for registration or authentication; credential handling must not store plaintext secrets. Before implementing identity-dependent cart behavior, create the planned short guest-checkout extension plan describing later cookie-based guest identification.

---

# Phase 5 — Cart + Order

## Weeks 7–8

Build:

### Cart

- Add item
- Remove item
- Quantity
- Refresh product prices when checkout begins and calculate the order total from current prices

### Order

- Create order
- Order items
- State machine
- Order history

Implement:

```text
Customer
   ↓
Cart
   ↓
Order
```

Use gRPC where an immediate cross-service response is necessary.

Use a mock payment service; do not integrate a real payment provider in the initial workflow. Use a mock delivery service with synthetic destination IDs, randomized status transitions over a configurable duration, and a 5% delivery failure rate. Tests must inject deterministic outcomes and contain no randomness. Do not store direct PII. Define data access, retention, and deletion rules for linkable user-ID analytics in a future phase before implementing analytics retention.

---

# Phase 6 — Redis

## Week 9

Implement:

- Product caching
- Category caching
- Cache-aside
- TTL
- Cache invalidation

Then create a Redis Cluster locally.

Target:

```text
3 Redis primaries
+
3 replicas
```

Learn:

- Hash slots
- Failover
- Replication
- Cache stampede
- Cache invalidation

---

# Phase 7 — Distributed Rate Limiting

## Week 10

Implement:

```text
Gateway
   │
   ▼
Redis Cluster
   │
   ├── allowed
   └── HTTP 429
```

Use token bucket.

Implement different limits for:

- Anonymous
- Authenticated users
- AI requests
- Admin

Test behavior with multiple gateway/service instances.

---

# Phase 8 — Kafka + Domain Events

## Weeks 11–12

Create:

```text
order-events
product-events
inventory-events
payment-events
analytics-events
notification-events
```

Implement:

- Producers
- Consumers
- Consumer groups
- Partitioning
- Retry
- Dead-letter topic
- Idempotent consumers

Create events:

```text
OrderCreated
OrderCancelled
ProductCreated
ProductUpdated
InventoryReserved
InventoryReleased
PaymentCompleted
PaymentFailed
```

---

# Phase 9 — Transactional Outbox + Saga

## Weeks 13–14

Implement Transactional Outbox.

Then implement order Saga:

```text
Order Created
      │
      ▼
Inventory Reservation
      │
      ▼
Payment
      │
      ▼
Order Confirmation
```

Failure:

```text
Payment Failed
      │
      ▼
Release Inventory
      │
      ▼
Cancel Order
```

Use:

- gRPC for immediate inventory operations
- Kafka for domain events
- Outbox for reliable event publication
- Idempotency for retries

This is the project's primary distributed-systems phase.

---

# Phase 10 — Cassandra

## Week 15

Learn Cassandra deeply enough to explain its design.

Deploy:

```text
Cassandra Node 1
Cassandra Node 2
Cassandra Node 3
```

Implement analytics:

```text
ProductViewed
SearchPerformed
ProductAddedToCart
OrderCreated
CustomerProductInterestRecorded
CustomerCategoryInterestRecorded
```

Store high-volume events.

Provide aggregates for most-searched products and most-added-to-cart products, plus product/category interests keyed by authenticated user ID. Do not include direct PII in events or analytics. The initial system has no deletion rules; define data-lifecycle and deletion behavior in a future phase before retaining this data.

Create query-driven tables.

Then test adding nodes.

Document:

```text
Why Cassandra?
Why this partition key?
What is the expected partition size?
What happens when a node fails?
How does adding nodes increase capacity?
```

---

# Phase 11 — Search Service

## Week 16

Build:

- Keyword search
- Category filtering
- Price filtering
- Brand filtering
- Attribute filtering
- Sorting
- Pagination

Expose search through gRPC:

```text
SearchProducts(request)
```

AI Service will later call this API.

---

# Phase 12 — AI + RAG

## Weeks 17–18

### Week 17

Build:

```text
Product
   ↓
Document
   ↓
Embedding
   ↓
Vector Store
```

Use Spring AI or LangChain4j.

### Week 18

Build:

```text
AI Service
     │
     │ gRPC
     ▼
Search Service
     │
     ├── Structured filters
     └── Semantic retrieval
              │
              ▼
        Candidate products
              │
              ▼
             LLM
```

Support:

```text
"Find laptops under ₹80k with 16GB RAM."

"Which phones are good for photography?"

"Show products suitable for programming."
```

Implement grounding.

---

# Phase 13 — Docker + Local Distributed Environment

## Week 19

Create Docker images for all services.

Create local environment containing:

```text
Gateway
Services
PostgreSQL
Redis Cluster
Kafka
Cassandra Cluster
Vector Store
AI Service
```

Use Docker Compose where practical for local development.

Test:

```text
multiple service instances
multiple Redis nodes
multiple Cassandra nodes
Kafka consumers
```

---

# Phase 14 — Kubernetes + Helm + Observability

## Week 20

Deploy services to Kubernetes.

Implement:

- Deployments
- Services
- ConfigMaps
- Secrets
- Ingress
- HPA
- Readiness probes
- Liveness probes
- Resource limits

Create Helm chart.

Add:

- Prometheus
- Grafana
- OpenTelemetry
- Centralized logging

Run failure experiments.

---

# 29. Weekly Working Pattern

For 1–2 hours/day:

## Day 1 — Learn

```text
45 min concept
30 min experiment
```

## Day 2 — Design

```text
30 min architecture
60 min implementation
```

## Day 3 — Implement

```text
60–120 min coding
```

## Day 4 — Implement/Test

```text
60–120 min coding + tests
```

## Day 5 — Interview Prep

```text
30 min documentation
30 min interview questions
```

## Weekend

Optional:

```text
1–3 hours
refactoring + diagrams + debugging
```

---

# 30. Limited AI Usage Strategy

Use AI as a mentor/reviewer rather than having it write the system.

Good prompts:

```text
"Review this aggregate for DDD violations."

"Does this service boundary make sense?"

"Review this gRPC contract for backward compatibility."

"Identify failure modes in this Saga."

"Give me test cases for this inventory reservation."

"Why might this Cassandra partition become hot?"

"Review this Kafka consumer for idempotency."

"Challenge this architecture as an interviewer."
```

Avoid:

```text
"Build the entire service for me."
```

The goal is that you can explain every line and architectural decision during an interview.

---

# 31. Definition of Done

Every phase should have four outputs.

## 1. Working code

Feature runs locally.

## 2. Tests

Unit + integration tests relevant to the feature.

## 3. Documentation

Document:

```text
Problem
Decision
Alternatives
Trade-offs
Failure modes
```

## 4. Interview notes

Answer:

```text
Why did I choose this?
What happens when it fails?
How does it scale?
What are the consistency guarantees?
What would change at 10x scale?
```

---

# 32. Architecture Decision Records

Create:

```text
ADR-001-ddd-bounded-contexts.md
ADR-002-monorepo.md
ADR-003-multiple-deployable-services.md
ADR-004-grpc-for-sync-communication.md
ADR-005-kafka-for-async-communication.md
ADR-006-postgresql-for-transactional-data.md
ADR-007-redis-cluster.md
ADR-008-distributed-rate-limiting.md
ADR-009-transactional-outbox.md
ADR-010-saga-order-workflow.md
ADR-011-cassandra-for-analytics.md
ADR-012-hybrid-rag.md
ADR-013-kubernetes.md
ADR-014-helm.md
ADR-015-observability.md
```

---

# 33. Important Interview Scenarios

You should eventually be able to whiteboard each of these.

## Scenario 1 — Inventory Reservation

```text
Order
  │
  │ gRPC
  ▼
Inventory
```

Questions:

- What if Inventory is down?
- What if the request times out?
- Can the request be retried?
- How do you prevent double reservation?

---

## Scenario 2 — Kafka Duplicate

```text
PaymentCompleted
PaymentCompleted
```

Questions:

- Why did it happen?
- How do you detect duplicates?
- Is the consumer idempotent?

---

## Scenario 3 — Redis Failure

Questions:

- Does the application stop?
- Can the cache be bypassed?
- What happens to rate limiting?
- What is the source of truth?

---

## Scenario 4 — Cassandra Node Failure

Questions:

- What happens to reads?
- What happens to writes?
- What does replication factor mean?
- What consistency level are you using?

---

## Scenario 5 — Payment Failure

```text
Inventory Reserved
       ↓
Payment Failed
```

Questions:

- How is inventory released?
- Which service owns the workflow?
- Is the system eventually consistent?

---

## Scenario 6 — gRPC Timeout

```text
Order → Inventory
```

Questions:

- Did Inventory process the request?
- Can Order retry?
- How do you make the operation idempotent?
- What deadline should be used?

---

## Scenario 7 — Service Scaling

```text
order-service

1 pod
 ↓
3 pods
 ↓
10 pods
```

Questions:

- Is the service stateless?
- Where is session state?
- How does Kubernetes distribute traffic?
- How does Kafka distribute work?
- What happens to database connections?

---

# 34. Final Interview Story

The project should tell this story:

> "I built a DDD-based e-commerce platform in a monorepo containing multiple independently deployable Spring Boot services. Each service owns its domain and persistence boundary. I use gRPC for low-latency synchronous service-to-service calls and Kafka for asynchronous domain events. Redis Cluster provides horizontally scalable caching and distributed rate limiting. Cassandra is used for high-volume analytics workloads and is deployed as a multi-node cluster. The order workflow uses Saga, transactional outbox, retries, and idempotency to handle distributed consistency. I added a hybrid RAG product assistant that combines semantic retrieval with structured product filters. The services are containerized and deployed using Kubernetes and Helm, with metrics, tracing, logging, and failure testing."

The important part is being able to defend every architectural decision.

---

# 35. Final Technology Checklist

## Java

- Java 21+
- Collections
- Streams
- Concurrency
- CompletableFuture
- Virtual threads awareness
- JVM fundamentals

## Spring

- Spring Boot
- Spring MVC
- Spring Data
- Spring Security
- Spring Transactions
- Spring Kafka
- Spring gRPC integration
- Spring AI
- Actuator

## DDD

- Bounded contexts
- Context mapping
- Aggregates
- Entities
- Value objects
- Domain events
- Application services
- Anti-corruption layer
- Repository abstraction

## gRPC

- Protocol Buffers
- Unary RPC
- Deadlines
- Status codes
- Interceptors
- Metadata
- Retries
- Idempotency
- Health checks
- Observability

## Kafka

- Topics
- Partitions
- Consumer groups
- Offsets
- Ordering
- Consumer lag
- Retries
- DLQ
- Idempotency
- Transactional Outbox

## Databases

- PostgreSQL
- Hibernate/JPA
- Redis Cluster
- Cassandra Cluster
- Vector database

## Distributed Systems

- Saga
- Eventual consistency
- Outbox
- Idempotency
- Retries
- Timeouts
- Circuit breaker awareness
- Backpressure
- Failure recovery

## Infrastructure

- Docker
- Kubernetes
- Helm
- Ingress
- HPA
- Resource limits

## Observability

- Prometheus
- Grafana
- OpenTelemetry
- Centralized logging
- Distributed tracing

## Testing

- JUnit
- Mockito
- Testcontainers
- REST Assured
- ArchUnit
- gRPC integration tests

---

# 36. Final Milestones

## Week 5

```text
Monorepo
+
DDD
+
Service boundaries
+
Spring Boot services
+
gRPC foundation
+
PostgreSQL
+
Hibernate
```

## Week 10

```text
Product
+
Customer
+
Cart
+
Order
+
Security
+
Redis Cluster
+
Rate Limiting
```

## Week 14

```text
Kafka
+
gRPC
+
Transactional Outbox
+
Saga
+
Idempotency
+
Distributed Order Workflow
```

## Week 16

```text
Cassandra Cluster
+
Analytics
+
Search Service
```

## Week 18

```text
AI
+
RAG
+
Hybrid Search
+
AI ↔ Search gRPC
```

## Week 20

```text
Docker
+
Kubernetes
+
Helm
+
Observability
+
Horizontal Scaling
+
Failure Testing
```

---

# 37. The Core Design Principle

Do not optimize the project for the number of technologies.

Optimize it for the number of **architectural decisions you can explain deeply**.

The ideal interview conversation should move naturally from:

```text
Business Domain
      ↓
DDD
      ↓
Bounded Contexts
      ↓
Service Boundaries
      ↓
gRPC vs Kafka
      ↓
Data Ownership
      ↓
PostgreSQL / Redis / Cassandra
      ↓
Saga + Outbox
      ↓
Consistency + Failure Handling
      ↓
Horizontal Scaling
      ↓
Kubernetes
      ↓
Observability
      ↓
AI/RAG
```

If you can confidently defend that entire chain, the project will serve as a strong system-design and backend interview preparation exercise.
