# SyncSeat DevOps Platform

A production-focused DevOps repository for the SyncSeat application, built to package, validate, secure, and deploy a multi-service booking platform using Docker, GitHub Actions, and GitOps automation.

This project is intentionally structured as a deployment and operations layer around the upstream application source, which is preserved under `syncseatapp/`. The goal is to keep the application code separate from the operational workflows, making it easier to build, test, scan, package, and promote the platform into Kubernetes-based environments through a companion GitOps repository.

## Project Overview

SyncSeat is a seat-booking and ticketing application designed around a microservice architecture. It enables users to browse shows, reserve seats, and complete the booking journey through a frontend experience supported by backend services for booking, authentication, mail, and homepage/content handling.

The original SyncSeat project was upstreamed into this repository and organized under `syncseatapp/` as the application source of truth. This DevOps repository adds the production-grade operations layer around that application:

- containerization for each service
- local orchestration with Docker Compose
- CI validation for backend services
- Docker image builds and artifact packaging
- Trivy-based security scanning
- Docker Hub publishing
- GitOps-driven promotion to Kubernetes environments

## Why this repository exists

This repository is not meant to replace the application code itself. It is the operational backbone for the application.

My contribution here is the end-to-end enablement layer:

- I upstreamed the original SyncSeat project into the `syncseatapp/` directory and kept it organized in a reusable structure.
- I created and maintained tailored Dockerfiles for the backend microservices and the frontend application.
- I built automation around the project using GitHub Actions to validate code, build images, and publish them securely.
- I integrated scanning and release workflows to prepare the application for deployment via GitOps.
- I connected the delivery flow to the infrastructure repository so environment configuration is updated automatically.

This makes the project multi-repository by design:

- Application source / DevOps build pipeline: `@phanivarun05/sync-seat-devops-eks`
- GitOps deployment repository: `@phanivarun05/sync-seat-gitops-eks`

## Multi-Repository Architecture

This repository and the GitOps repository work together as a single platform delivery flow.

### 1) Application + DevOps Repository
This repo contains:

- the imported upstream SyncSeat application source in `syncseatapp/`
- Docker build definitions for all services
- CI workflows in `.github/workflows/`
- Docker Compose definitions for local deployment
- image build automation and validation
- production promotion logic

### 2) GitOps Repository
The GitOps repository is:

- `@phanivarun05/sync-seat-gitops-eks`

It holds the deployment manifests and Helm values used to roll the application into Kubernetes environments. The DevOps repo automatically updates the image tags in that repository during the promotion process, allowing deployment configuration to be managed declaratively rather than manually.

## Original SyncSeat Project

The underlying SyncSeat platform is a ticket-booking application with a microservice architecture. The original project includes:

- an API gateway for request routing and authentication
- a booking service for seat reservation and transactional flows
- a mail service for asynchronous notifications
- a homepage/media service for public-facing content
- a frontend application for user interaction

The application design uses asynchronous job processing and Redis-based coordination to handle seat locking and reservation workflows safely. This is reflected in the upstream source structure under `syncseatapp/Backend` and `syncseatapp/Frontend`.

## What I implemented in this DevOps project

This repository focuses on operationalizing the original project and making it deployment-ready.

### Containerization

I created a reusable backend Docker image approach using `docker/generic/Dockerfile`, which builds individual microservices by passing the service path as a build argument.

The project also includes a dedicated frontend build workflow in `docker/frontend/Dockerfile` using Node + Vite build and Nginx for serving static assets.

### Local orchestration

The project includes `docker/docker-compose.yml`, which defines the full local stack including:

- PostgreSQL
- Redis
- booking service
- mail service
- homepage service
- API gateway
- frontend

This gives a consistent development and validation environment for the platform.

### CI/CD automation

The GitHub Actions workflows in `.github/workflows/` automate the following:

- backend dependency installation and test validation
- Docker image builds for the full platform
- artifact packaging and upload
- security scanning using Trivy
- Docker Hub publication of validated images
- GitOps repository updates for environment promotion

Key workflows:

- `ci.yml` — CI validation, image build, security scan, and registry publishing
- `promotion-prod.yaml` — promotes immutable image tags into production values files in the GitOps repo

### Security and quality controls

The project includes security hardening practices such as:

- Trivy scanning with ignore configuration via `.trivyignore`
- production-safe Node runtime settings
- non-root container execution
- dependency installation tuned for runtime builds
- image validation before registry release

### Build tooling

The `Makefile` provides a clear build interface for the platform and includes targets for:

- building backend services
- building the frontend image
- building all Docker images
- running security scans

## Repository Structure

```text
sync-seat-devops-eks/
├── .github/
│   └── workflows/
│       ├── ci.yml
│       └── promotion-prod.yaml
├── docker/
│   ├── docker-compose.yml
│   ├── frontend/
│   │   └── Dockerfile
│   └── generic/
│       └── Dockerfile
├── docs/
├── syncseatapp/
│   ├── Backend/
│   ├── Frontend/
│   ├── README.md
│   └── README-INTERVIEW.md
├── .dockerignore
├── .gitignore
├── .trivyignore
├── Makefile
├── README.md
└── LICENSE
```

## Deployment flow

The operational flow is designed as follows:

1. Application code is maintained and upstreamed into `syncseatapp/`
2. CI validates the backend microservices and builds Docker artifacts
3. Trivy security scans the generated images
4. Verified images are pushed to Docker Hub
5. A GitOps promotion workflow updates the deployment repository
6. The GitOps repo applies those changes to the Kubernetes environment

This architecture separates application logic from infrastructure definition while keeping the delivery process automated and repeatable.

## Quick start

### Run locally with Docker Compose

```bash
docker compose -f docker/docker-compose.yml up --build
```

### Build all Docker images

```bash
make build-docker
```

### Run vulnerability scan

```bash
make security-scan
```

## Key takeaway

This repository demonstrates a complete DevOps implementation around the SyncSeat application. The original upstream project is preserved and respected, while the operational side of the platform is strengthened through automation, containerization, security validation, and GitOps-based deployment management.

The most important contribution is not just infrastructure setup, but the ability to take an upstream application and turn it into a clean, deployable, production-oriented platform with repeatable operational workflows.

## Related repositories

- Application and DevOps repo: `@phanivarun05/sync-seat-devops-eks`
- GitOps deployment repo: `@phanivarun05/sync-seat-gitops-eks`

## License

This project is released under the repository's existing license terms. Please review the repo files for the precise licensing details applicable to the project.
