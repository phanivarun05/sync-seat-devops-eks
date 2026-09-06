                      ┌────────────────────────────────────────┐
                      │             Web Browser                │
                      │   (React Frontend @ localhost:9000)    │
                      └───────────────────┬────────────────────┘
                                          │
                                          │ HTTP Requests
                                          ▼
                      ┌────────────────────────────────────────┐
                      │          Nginx Web Server              │
                      │  - Serves Static React Assets          │
                      │  - Acts as Reverse Proxy for CORS      │
                      └───────────────────┬────────────────────┘
                                          │
                                          │ Proxies /api/ to Port 4000
                                          ▼
                      ┌────────────────────────────────────────┐
                      │           API Gateway Container        │
                      │  - Listens on Port 4000                │
                      │  - Centralised Auth / Route Forwarding │
                      └───────┬────────────────────────┬───────┘
                              │                        │
        Internal Forwarding   │                        │ Internal Forwarding
        to Port 3001          ▼                        ▼ to Port 3003
  ┌───────────────────────────────────┐      ┌───────────────────────────────────┐
  │     Booking Service Container     │      │    Homepage Service Container     │
  │     - Core Reservation Logic      │      │    - Media / Upload Storage       │
  │     - Listens on Port 3001        │      │    - Listens on Port 3003        │
  └─────┬───────────────────────┬─────┘      └─────────────────┬─────────────────┘
        │                       │                              │
        │ Writes Locks /        │ Enqueues                     │
        │ Status Checks         │ `bookingQueue`               │
        │                       │                              │ Queries Public 
        │                       ▼                              │ Pages Data
        │         ┌───────────────────────────┐                │
        │         │   Redis Cache & Broker    │                │
        │         │   (redis:7-alpine @ 6379) │                │
        │         │   - Ephemeral Seat Locks  │                │
        │         │   - BullMQ Queue Storage  │                │
        │         └─────────────▲─────────────┘                │
        │                       │                              │
        │                       │ Consumes `mailQueue`         │
        │                       │                              │
        │         ┌─────────────┴─────────────┐                │
        │         │   Mail Service Container  │                │
        │         │   - Asynchronous Worker   │                │
        │         │   - Listens on Port 3002  │                │
        │         └───────────────────────────┘                │
        │                                                      │
        └───────────────────────┐                              │
                                │                              │
                                ▼                              ▼
                  ┌──────────────────────────────────────────────────────────┐
                  │                PostgreSQL Main Database                  │
                  │                 (postgres:16-alpine @ 5432)              │
                  │                 - Authoritative Durable State            │
                  │                 - Maps to SUPABASE_URL Env               │
                  └─────────────────────────────▲────────────────────────────┘
                                                │
                                                │ Scans & Reconciles 
                                                │ Expired 'LOCKED' Rows
                                                │
                                  ┌─────────────┴─────────────┐
                                  │   Lock Cleanup Worker     │
                                  │   (Standalone Node Task)  │
                                  └───────────────────────────┘