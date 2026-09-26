# Business Scope and Requirements

## Status and Source

**Scope reviewed with the project owner.** This document translates the goals and candidate workflows in [`plans/project_plan.md`](../../plans/project_plan.md) into a concise business scope for Phase 0. The platform has no service implementation yet, so these are requirements for the planned learning project, not claims about running behavior. Confirmed requirements are distinguished from unresolved implementation details below.

## Goal and Audience

Build a deliberately small but technically deep e-commerce system for backend and system-design interview preparation. The primary audience is the developer building and explaining the system, followed by interviewers or reviewers evaluating its domain boundaries and engineering trade-offs.

The system should provide a coherent path through product discovery and order processing, while making it possible to explain service ownership, synchronous and asynchronous communication, consistency, failure handling, and scaling. It is not intended to reproduce the feature breadth of a large marketplace.

## System Scope

The project scope is a single-seller e-commerce learning platform. The planned capabilities are:

- Maintain and present a product catalog.
- Allow anonymous product browsing; require authentication before adding items to a cart or checking out.
- Let an authenticated customer collect products in a cart and submit an order.
- Refresh product prices when checkout begins.
- Reserve all requested inventory or none of it, with one configurable 15-minute reservation timeout shared across products.
- Use a mock payment service and advance or compensate an order from its result.
- Use a mock delivery service to simulate status changes for synthetic destinations; delivery simulation has a configurable duration and a 5% failure rate.
- Support structured and natural-language product discovery.
- Consume business events for aggregate product metrics and customer-ID-keyed product/category interests without putting analytics work on the synchronous order path.
- Store no direct PII. Authenticated records use the user's ID; order and analytics records may include that ID, order details, and product interests. No deletion rules are defined initially; define them in a future phase.

These capabilities and their service mapping are requirements for later phases; they are not implemented in the current repository.

## Candidate User Journeys

### 1. Discover a product

1. An unauthenticated shopper browses or searches the catalog using structured criteria.
2. The system returns matching product information.
3. The shopper may ask the product assistant a natural-language question; its answer must be grounded in product information rather than invented facts.
4. Authentication is not required for browsing or searching.

**Grounded in plan and confirmed:** Product Catalog, Search, and AI Assistant capabilities; hybrid structured and semantic retrieval; anonymous browsing. Search behavior, catalog publication rules, and the exact relationship between catalog and search remain to be designed.

### 2. Build a cart and submit an order

1. A shopper can browse without authenticating.
2. The shopper must authenticate before adding products and quantities to a cart and before checkout. Associate authenticated activity with the user's ID.
3. At checkout, the system associates the order with an opaque customer ID. It stores order details but no direct PII or real shipping address.
4. When checkout begins, refresh product prices and calculate the checkout total from current prices. The cart price is not a price lock. If the refreshed total differs from the amount last shown, display the new total and require the shopper to confirm before submitting the order.
5. The order workflow reserves all requested inventory or none. One configurable 15-minute timeout applies uniformly across all products.
6. The order uses a synthetic destination identifier for mock delivery, not a real address.

**Confirmed:** Authentication is required for cart changes and checkout but not browsing; authenticated activity uses a user ID; prices refresh when checkout begins and a changed total requires confirmation; reservation is all-or-nothing with a uniform configurable 15-minute timeout; delivery uses synthetic destinations. Cart expiration and remaining checkout validation rules are unspecified.

### 3. Complete or compensate an order

1. Once inventory is reserved and the order is created, a mock payment service returns a simulated outcome; no real payment provider is integrated.
2. On simulated payment success, the order is confirmed and can proceed to mock fulfillment.
3. On simulated payment failure, the workflow releases the full reservation and cancels the order.

**Grounded in plan and confirmed:** `OrderCreated`, `PaymentCompleted`, `PaymentFailed`, `OrderConfirmed`, `OrderCancelled`, inventory reservation/release, and Saga compensation; payment is mocked. Retry limits, duplicate-event behavior, timeout handling, and whether the mock response is synchronous or asynchronous remain for the relevant implementation plan.

### 4. Fulfill and notify

1. A confirmed order is handed to a mock delivery service with a synthetic destination identifier.
2. The service simulates delivery status changes across multiple synthetic destinations during a configured duration.
3. Exactly 5% of simulated deliveries fail; the other 95% succeed.

**Confirmed:** Delivery must be simulated, vary by destination, complete within a configurable duration, and fail 5% of the time. Production simulation may use randomness; tests must inject deterministic outcomes and contain no randomness. The exact state machine, duration value, and notification behavior remain to be designed. Use synthetic destination IDs only.

### 5. Record activity for analytics

1. The system records the most-searched products and the products most frequently added to carts.
2. It tracks product and category interests by opaque customer ID.
3. Analytics consumes the required events independently of the user-facing transaction.

**Confirmed:** The initial analytics include most-searched products, most-added-to-cart products, and product/category interests per customer ID. **Grounded in plan:** Kafka is proposed for asynchronous events. Event definitions, time windows, retention, aggregation details, and privacy controls remain to be designed. No deletion rules are defined for the initial system; a future phase must establish data-lifecycle rules.

## Candidate Business Rules

The following requirements are confirmed by the project owner or stated in the project plan:

1. Each service owns its data. A service must not read or write another service's private database directly.
2. Inventory availability cannot be negative: `AvailableStock >= 0`.
3. Inventory reservation is all-or-nothing.
4. When checkout begins, refresh product prices. If the total changes, display the refreshed total and require customer confirmation before order submission.
5. A single configurable 15-minute inventory reservation timeout applies uniformly to all products.
6. Payment and delivery are mock services; no real payment provider or carrier is integrated.
7. A payment failure triggers full inventory release and order cancellation.
8. Delivery simulation spans synthetic destinations, finishes within a configurable duration, and has a 5% failure rate. Tests use deterministic injected outcomes, not randomness.
9. Analytics records search popularity, cart-add popularity, and product/category interests keyed by customer ID.
10. Do not store direct PII, including names, email addresses, phone numbers, real street addresses, or payment credentials, in databases, event payloads, logs, or analytics. Authenticated records may use the user's ID with order details or product/category interests.
11. Product-assistant answers must be grounded in product facts and must not invent catalog details.
12. Analytics processing must not be required to complete a user-facing order request.

The plan does not yet define important rules such as currency and rounding, duplicate requests/events, cancellation after payment, or the configurable delivery duration. These are open questions, not implicit defaults. Partial inventory reservation is explicitly disallowed.

## Explicit Non-Goals

- Recreating Amazon or building a broad commercial marketplace.
- Supporting multiple sellers in the initial implementation.
- Supporting guest carts or guest checkout in the initial implementation.
- Integrating a real payment provider or delivery carrier.
- Implementing all planned platform capabilities in the first end-to-end slice.
- Solving every large-scale production concern before the basic domain boundaries and workflows are understood.

The project's purpose is to build a small system whose important design decisions and trade-offs can be explained in depth.

## Future Extensibility Requirements

- **Multiple sellers:** The first implementation is single-seller. Avoid choices that unnecessarily prevent seller ownership from being introduced later, but do not implement multi-seller behavior now. Before implementing the catalog/order ownership decisions, create a short future-extension plan in the relevant phase folder describing likely domain/API/data changes, migration path, compatibility risks, and tests for adding sellers.
- **Guest checkout:** The first implementation requires authentication to add to cart and check out, and uses the authenticated user's ID. Keep the boundary extensible so guest users can later be identified with a browser cookie, but do not implement guest carts or checkout now. Before implementing the cart/checkout identity boundary, create a short future-extension plan in the relevant phase folder covering cookie identity, expiration and security attributes, cart conversion/claiming, order ownership, abuse controls, migration, and tests.
- **Linkable behavioral data:** The owner permits user IDs associated with product/category interests and order details. Such data has no direct identifiers but is linkable behavioral data and may still be classified as personal data. Treat it as sensitive. No deletion rules exist in the initial scope; a future phase must define data access, retention, deletion, and event/log handling before analytics is implemented.
- **Synthetic delivery destinations:** Use non-identifying destination IDs or labels for the mock service. Do not store real customer addresses.
- **Mock simulation parameters:** Use a configurable 15-minute uniform reservation timeout and a configurable delivery duration. The delivery failure rate is 5%; tests must inject deterministic outcomes. Delivery states remain to be selected in implementation plans.

## Remaining Questions for Project-Owner Review

1. Which delivery states should the mock expose?

## Phase Handoff

- **Phase 1:** Use the reviewed business boundaries to confirm service names and responsibilities before adding Spring Boot skeletons. Skeletons must not imply unreviewed APIs or cross-service database access.
- **Phase 2:** Use the reviewed immediate interactions to select the first customer, product, and inventory contracts. Define schemas, status codes, deadlines, and compatibility rules in Phase 2 rather than in this business-scope document.
- **Relevant implementation phases:** Before implementing seller ownership or cart/checkout identity boundaries, add the respective short multi-seller or guest-checkout extension plan to that phase's plan folder as described above.
- **Future privacy work:** Before retaining customer-ID-linked analytics, define access, retention, and deletion rules in a later phase; the initial system has no deletion behavior.

## References

- [Overall project plan](../../plans/project_plan.md)
- [Phase 0 plan](../../plans/phase-00-domain-discovery-architecture/plan.md)
- [Phase 0 tasks](../../plans/phase-00-domain-discovery-architecture/tasks.md)
