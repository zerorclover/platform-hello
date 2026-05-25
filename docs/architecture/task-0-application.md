# Task 0 Application Design

## Purpose

This repository contains a compact multi-tier application for the Senior Platform Engineer test. The application is intentionally small, with clear deployment boundaries for infrastructure, CI/CD, and policy automation.

## Components

- Frontend: static HTML, CSS, and JavaScript served by Nginx.
- Backend: Node.js REST API using the built-in HTTP server.
- Database: PostgreSQL storing `items`.

## Request Flow

```mermaid
sequenceDiagram
  participant User
  participant Web as Frontend / Nginx
  participant API as Backend API
  participant DB as PostgreSQL

  User->>Web: Open application
  Web->>API: GET /api/message
  Web->>API: GET /api/items
  API->>DB: SELECT items
  DB-->>API: rows
  API-->>Web: JSON
  Web-->>User: Render message and items
```
