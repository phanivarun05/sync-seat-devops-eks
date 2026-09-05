
# ============================================================
# Docker Configuration
# ============================================================

DOCKERFILE_BACKEND := docker/generic/Dockerfile

IMAGE_PREFIX := syncseatapp
TAG ?= latest

.PHONY: \
	booking api-gateway mail \
	build-backend security-scan clean

booking:
	docker build -f $(DOCKERFILE_BACKEND) \
		--build-arg SERVICE_PATH=booking \
		-t $(IMAGE_PREFIX)/booking:$(TAG) .

api-gateway:
	docker build -f $(DOCKERFILE_BACKEND) \
		--build-arg SERVICE_PATH=api-gateway \
		-t $(IMAGE_PREFIX)/api-gateway:$(TAG) .

mail:
	docker build -f $(DOCKERFILE_BACKEND) \
		--build-arg SERVICE_PATH=mail \
		-t $(IMAGE_PREFIX)/mail:$(TAG) .

homepage:
	docker build -f $(DOCKERFILE_BACKEND) \
		--build-arg SERVICE_PATH=homepage \
		-t $(IMAGE_PREFIX)/homepage:$(TAG) .


build-backend: \
	booking \
	api-gateway \
	mail \
	homepage

# ============================================================
# Security Scanning
# ============================================================

# Services built using the generic Go Dockerfile
BACKEND_SERVICES = \
	booking \
	api-gateway \
	mail \
	homepage

TRIVY := trivy
SECURITY_SEVERITY := HIGH,CRITICAL

security-scan:
	@echo "========================================"
	@echo "Running Trivy security scans"
	@echo "Severity: $(SECURITY_SEVERITY)"
	@echo "========================================"

	@for service in $(BACKEND_SERVICES); do \
		echo ""; \
		echo "Scanning $(IMAGE_PREFIX)/$$service:$(TAG)"; \
		$(TRIVY) image \
			--severity $(SECURITY_SEVERITY) \
			--exit-code 1 \
			$(IMAGE_PREFIX)/$$service:$(TAG); \
	done

	@echo ""
	@echo "========================================="
	@echo "All security scans passed"
	@echo "========================================="