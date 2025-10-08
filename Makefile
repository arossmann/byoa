# BYOA - Build Your Own Agent Makefile
# A comprehensive Makefile for building, running, and managing the BYOA Go application

# Variables
BINARY_NAME=byoa
GO_FILES=$(wildcard *.go)
LDFLAGS=-ldflags "-w -s"
MAIN_PATH=.

# Default target
.PHONY: all
all: build

# Build the application
.PHONY: build
build: $(BINARY_NAME)

$(BINARY_NAME): $(GO_FILES) go.mod go.sum
	@echo "Building $(BINARY_NAME)..."
	go build $(LDFLAGS) -o $(BINARY_NAME) $(MAIN_PATH)
	@echo "✓ Build complete: $(BINARY_NAME)"

# Run the application
.PHONY: run
run: build
	@if [ -z "$$ANTHROPIC_API_KEY" ]; then \
		echo "❌ ANTHROPIC_API_KEY environment variable is required"; \
		echo "Set it with: export ANTHROPIC_API_KEY=your_key_here"; \
		echo "Or create a .env file and run: make run-env"; \
		exit 1; \
	fi
	@echo "Starting BYOA application..."
	./$(BINARY_NAME)

# Run with environment file
.PHONY: run-env
run-env: build
	@if [ ! -f ".env" ]; then \
		echo "❌ .env file not found"; \
		echo "Create a .env file with: ANTHROPIC_API_KEY=your_key_here"; \
		exit 1; \
	fi
	@echo "Loading environment from .env and starting application..."
	@set -a && . ./.env && set +a && ./$(BINARY_NAME)

# Test the application
.PHONY: test
test:
	@echo "Running Go tests..."
	go test -v ./...

# Run the test script
.PHONY: test-script
test-script: build
	@echo "Running test script..."
	./test.sh

# Clean build artifacts
.PHONY: clean
clean:
	@echo "Cleaning build artifacts..."
	rm -f $(BINARY_NAME)
	go clean
	@echo "✓ Clean complete"

# Download and tidy dependencies
.PHONY: deps
deps:
	@echo "Downloading and tidying dependencies..."
	go mod download
	go mod tidy
	@echo "✓ Dependencies updated"

# Format Go code
.PHONY: fmt
fmt:
	@echo "Formatting Go code..."
	go fmt ./...
	@echo "✓ Code formatted"

# Lint Go code (requires golangci-lint)
.PHONY: lint
lint:
	@echo "Linting Go code..."
	@which golangci-lint > /dev/null || (echo "❌ golangci-lint not installed. Install with: go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest" && exit 1)
	golangci-lint run
	@echo "✓ Linting complete"

# Vet Go code
.PHONY: vet
vet:
	@echo "Vetting Go code..."
	go vet ./...
	@echo "✓ Vet complete"

# Install the binary to $GOPATH/bin
.PHONY: install
install: build
	@echo "Installing $(BINARY_NAME) to $$GOPATH/bin..."
	go install $(LDFLAGS) $(MAIN_PATH)
	@echo "✓ Installation complete"

# Development target - format, vet, and build
.PHONY: dev
dev: fmt vet build
	@echo "✓ Development build complete"

# Full check - format, vet, test, and build
.PHONY: check
check: fmt vet test build
	@echo "✓ All checks passed"

# Full check with linting - format, vet, lint, test, and build
.PHONY: check-lint
check-lint: fmt vet lint test build
	@echo "✓ All checks passed (including lint)"

# Show help
.PHONY: help
help:
	@echo "BYOA - Build Your Own Agent Makefile"
	@echo ""
	@echo "Available targets:"
	@echo "  build       - Build the application"
	@echo "  run         - Run the application (requires ANTHROPIC_API_KEY)"
	@echo "  run-env     - Run with .env file"
	@echo "  test        - Run Go tests"
	@echo "  test-script - Run the test.sh script"
	@echo "  clean       - Remove build artifacts"
	@echo "  deps        - Download and tidy dependencies"
	@echo "  fmt         - Format Go code"
	@echo "  lint        - Lint Go code (requires golangci-lint)"
	@echo "  vet         - Vet Go code"
	@echo "  install     - Install binary to $$GOPATH/bin"
	@echo "  dev         - Format, vet, and build (development workflow)"
	@echo "  check       - Run all checks and build (lint optional)"
	@echo "  check-lint  - Run all checks including lint"
	@echo "  help        - Show this help message"
	@echo ""
	@echo "Examples:"
	@echo "  make build                    # Build the application"
	@echo "  ANTHROPIC_API_KEY=xxx make run  # Run with API key"
	@echo "  make run-env                  # Run with .env file"
	@echo "  make dev                      # Development workflow"

# Create a sample .env file
.PHONY: env-sample
env-sample:
	@if [ ! -f ".env" ]; then \
		echo "Creating sample .env file..."; \
		echo "ANTHROPIC_API_KEY=your_anthropic_api_key_here" > .env.sample; \
		echo "✓ Created .env.sample - copy it to .env and add your API key"; \
	else \
		echo "❌ .env file already exists"; \
	fi

# Show project status
.PHONY: status
status:
	@echo "BYOA Project Status:"
	@echo "==================="
	@printf "Go version: "; go version
	@printf "Binary exists: "; if [ -f "$(BINARY_NAME)" ]; then echo "✓ Yes"; else echo "❌ No (run 'make build')"; fi
	@printf "Dependencies: "; if go list -m all > /dev/null 2>&1; then echo "✓ OK"; else echo "❌ Issues (run 'make deps')"; fi
	@printf "API Key set: "; if [ -n "$$ANTHROPIC_API_KEY" ]; then echo "✓ Yes"; else echo "❌ No"; fi
	@printf ".env file: "; if [ -f ".env" ]; then echo "✓ Exists"; else echo "❌ Missing"; fi
