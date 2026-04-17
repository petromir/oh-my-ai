# Docker Runtime and Security Best Practices

While Dockerfiles define how an image is built, these best practices cover the security and management of containers at runtime and during the development lifecycle.

## 1. Runtime Security

*   **Protect the Docker Socket:** `/var/run/docker.sock` is a highly privileged gateway. Ensure it has restricted permissions and never expose it over unprotected TCP.
*   **Drop Capabilities:** Use the `--cap-drop` flag in Docker or `securityContext.capabilities.drop` in Kubernetes to restrict the container's kernel capabilities to the absolute minimum.
*   **Read-Only Filesystem:** Whenever possible, run containers with a read-only root filesystem (`--read-only`) to prevent attackers from writing malicious files or modifying the environment.
*   **Limit Resources:** Use flags to limit CPU and memory usage to prevent a single compromised or buggy container from consuming all host resources (DoS).

## 2. Image Management

*   **Sign and Verify Images:** Use Docker Content Trust, Notary, or similar tools to digitally sign images and verify their signatures before running them.
*   **Scan for Vulnerabilities:** 
    *   **Shift Left:** Scan images locally during development and in CI/CD pipelines before pushing to a registry.
    *   **Continuous Scanning:** Periodically re-scan images in production, as new vulnerabilities (CVEs) are discovered daily for existing software.
*   **Tag Mutability Awareness:** Be aware that tags (like `v1.0`) can be moved to different image versions. Use immutable digests for critical production deployments to ensure you run exactly what was tested and scanned.

## 3. Health and Monitoring

*   **Health Checks:** Include a `HEALTHCHECK` instruction in your Dockerfile (for Docker/Swarm) or use `livenessProbes` and `readinessProbes` in Kubernetes to allow the system to automatically detect and recover from failed services.
*   **Logging:** Ensure applications log to `stdout` and `stderr` to follow the 12-factor app methodology and allow the container runtime to handle log collection.

## 4. Host Integration

*   **Avoid Rootless Containers if Possible:** While "Rootless Docker" is a feature, most guidance focuses on running the *application* as a non-root user *inside* a standard container.
*   **Sensitive Mounts:** Avoid bind-mounting sensitive host directories (like `/etc`, `/usr`, or the Docker socket) into containers unless absolutely necessary.
*   **Sticky Bit on /tmp:** When writing temporary data, use `/tmp` which typically has the sticky bit set, allowing any UID to write to it safely.

## 5. Development Workflow

*   **Use Linters:** Integrate tools like `hadolint` into your IDE and CI pipeline to catch Dockerfile smells and security issues early.
*   **Minimize Context:** Always use a `.dockerignore` file to ensure secrets and unnecessary large files aren't sent to the Docker daemon during the build.
