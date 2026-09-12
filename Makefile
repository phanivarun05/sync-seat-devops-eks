
# ============================================================
# Docker Configuration
# ============================================================

DOCKERFILE_BACKEND := docker/generic/Dockerfile
DOCKERFILE_FRONTEND := docker/frontend/Dockerfile

IMAGE_PREFIX := syncseatapp
TAG ?= latest

.PHONY: \
	booking api-gateway mail homepage \
	build-backend build-frontend security-scan clean

booking:
	docker build -f $(DOCKERFILE_BACKEND) \
		--build-arg SERVICE_PATH=booking \
		-t $(IMAGE_PREFIX)-booking:$(TAG) .

api-gateway:
	docker build -f $(DOCKERFILE_BACKEND) \
		--build-arg SERVICE_PATH=api-gateway \
		-t $(IMAGE_PREFIX)-api-gateway:$(TAG) .

mail:
	docker build -f $(DOCKERFILE_BACKEND) \
		--build-arg SERVICE_PATH=mail \
		-t $(IMAGE_PREFIX)-mail:$(TAG) .

homepage:
	docker build -f $(DOCKERFILE_BACKEND) \
		--build-arg SERVICE_PATH=homepage \
		-t $(IMAGE_PREFIX)-homepage:$(TAG) .


build-backend: \
	booking \
	api-gateway \
	mail \
	homepage

build-frontend:
	docker build -f $(DOCKERFILE_FRONTEND) \
		-t $(IMAGE_PREFIX)-frontend:$(TAG) .

build-docker: build-backend build-frontend

# ============================================================
# Security Scanning
# ============================================================

# Services built using the generic Javascript Dockerfile
JAVASCRIPT_SERVICES = \
	booking \
	api-gateway \
	mail \
	homepage

WEB_SERVICES = \
	frontend

TRIVY := trivy
SECURITY_SEVERITY := HIGH,CRITICAL

security-scan:
	@echo "========================================"
	@echo "Running Trivy security scans"
	@echo "Severity: $(SECURITY_SEVERITY)"
	@echo "========================================"

	@for service in $(JAVASCRIPT_SERVICES); do \
		echo ""; \
		echo "Scanning $(IMAGE_PREFIX)-$$service:$(TAG)"; \
		$(TRIVY) image \
			--severity $(SECURITY_SEVERITY) \
			--exit-code 1 \
			$(IMAGE_PREFIX)-$$service:$(TAG); \
	done

	@for service in $(WEB_SERVICES); do \
		echo ""; \
		echo "Scanning $(IMAGE_PREFIX)-$$service:$(TAG)"; \
		$(TRIVY) image \
			--severity $(SECURITY_SEVERITY) \
			--exit-code 1 \
			$(IMAGE_PREFIX)-$$service:$(TAG); \
	done

	@echo ""
	@echo "========================================="
	@echo "All security scans passed"
	@echo "========================================="