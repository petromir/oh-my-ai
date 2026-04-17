# Dockerfile Best Practices

This document compiles the best practices for writing efficient, secure, and maintainable Dockerfiles, gathered from multiple authoritative sources.

## 1. General Principles

*   **Create Ephemeral Containers:** The image defined by your Dockerfile should generate containers that are as ephemeral as possible—meaning they can be stopped, destroyed, rebuilt, and replaced with minimal setup.
*   **Decouple Applications (Single Concern):** Each container should have only one concern. Limiting each container to one process is a good rule of thumb, though not a hard rule (e.g., init processes).
*   **Don't Install Unnecessary Packages:** Avoid "nice-to-have" packages to reduce complexity, file size, and build times.
*   **Minimize Layers:** Combine related commands (especially `RUN` instructions) to reduce the number of layers.
*   **Sort Multi-line Arguments:** Sort arguments (like package lists) alphanumerically to avoid duplicates and improve readability/PR reviews.

## 2. Base Image Strategy

### Choosing the Right Image
*   **Use Official Images:** Start with official, trusted, and verified images (e.g., Docker Official Images, Verified Publishers).
*   **Minimize Size:** Smaller base images (Alpine, Distroless) offer portability, faster downloads, and a smaller attack surface.
*   **Alpine vs. Others:** While Alpine is recommended for its small size (< 6MB), be aware that it may have performance issues with certain technologies (e.g., Python) and some security scanners may struggle with its package format.
*   **Distroless Images:** Consider "distroless" images for production; they contain only your application and its runtime dependencies, excluding shell and package managers.

### Image Tagging
*   **Avoid `latest`:** Using `latest` makes builds non-reproducible and prone to breaking.
*   **Pin to `major.minor` Versions:** This ensures reproducibility while still allowing you to receive patch-level security updates when rebuilding.
*   **Pin to SHA Digest:** For maximum security and supply chain integrity, pin to the image digest (e.g., `image:tag@sha256:...`). Use tools like Docker Scout or `docker-lock` to manage the trade-off between reproducibility and automated security updates.

## 3. Instruction Best Practices

### FROM
*   Use current official images as a basis.
*   Prefer minimal distributions like Alpine or Debian Slim.

### RUN
*   **Chain Commands:** Use `&&` to combine commands to reduce layers.
*   **Clean Up Immediately:** Remove temporary files (like apt caches) in the same `RUN` layer they were created (e.g., `rm -rf /var/lib/apt/lists/*`).
*   **Pipes:** Use `set -o pipefail` to ensure that a failure in any part of a command pipe causes the build to fail.
*   **apt-get:** Always combine `apt-get update` with `apt-get install` in the same statement to prevent caching issues ("cache busting"). Use `--no-install-recommends`.

### CMD & ENTRYPOINT
*   **Preferred Form:** Always use the **exec form**: `["executable", "param1", "param2"]`.
*   **Roles:** Use `ENTRYPOINT` for the main command (making the image behave like a binary) and `CMD` for default arguments that can be easily overridden.
*   **Init Processes:** For multi-process containers, consider using an init process like `tini`.

### COPY & ADD
*   **Prefer COPY:** It is more explicit and predictable.
*   **Use ADD Sparingly:** Only use `ADD` for its specific features: auto-extracting local tar files or fetching remote URLs with checksum validation.
*   **Bind Mounts:** For temporary build dependencies (like `requirements.txt`), consider using `--mount=type=bind` in a `RUN` instruction to avoid persisting them in the image.

### USER
*   **Run as Non-Root:** Always change to a non-root user using the `USER` instruction.
*   **UID Selection:** Use a UID/GID above 10,000 to avoid overlapping with privileged host users.
*   **Static ID:** Use a static UID/GID for consistent file permission management.
*   **Permissions:** Ensure executables are owned by root and not writable by the application user to prevent runtime modification.

### WORKDIR
*   **Absolute Paths:** Always use absolute paths for clarity and reliability.
*   **Avoid `RUN cd`:** Use `WORKDIR` instead of chaining `cd` commands.

### ENV & ARG
*   **Versioning:** Use `ENV` to set version numbers for easier maintenance.
*   **Secrets:** **NEVER** store secrets (API keys, credentials) in `ENV` or `ARG` as they persist in the image layers. Use runtime environment variables or secret management systems.

### VOLUME
*   **Mutable Data:** Use `VOLUME` for database storage, configuration storage, or any mutable parts of the image.

## 4. Build Cache Optimization

*   **Order Matters:** Place instructions that change frequently (like application code) at the bottom, and stable instructions (like OS package installs) at the top.
*   **Layer Caching:** Structure your Dockerfile to maximize cache hits. For example, copy dependency files (e.g., `package.json`, `pom.xml`) and run the install step *before* copying the rest of the source code.

## 5. Build Context

*   **Use `.dockerignore`:** Exclude irrelevant files (e.g., `.git`, `node_modules`, `*.md`, secrets) to reduce build context size and prevent accidental leaks.
*   **Small Context:** Only include the files necessary for the build in the context directory.
