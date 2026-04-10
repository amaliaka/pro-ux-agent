ARG OPENCODE_IMAGE=ghcr.io/anomalyco/opencode:latest
FROM ${OPENCODE_IMAGE} AS skills-builder

USER root

ARG ENGRAM_VERSION=latest
ARG SUPERPOWERS_REF=main
ARG UI_UX_PRO_MAX_REF=main
ARG IMPECCABLE_REF=main
ARG PLAYWRIGHT_CLI_REF=main
ARG AGENT_BROWSER_REF=main
ARG PLAYWRIGHT_CLI_VERSION=latest
ARG PLAYWRIGHT_VERSION=latest
ARG PLAYWRIGHT_BROWSER_CHANNEL=chromium
ARG AGENT_BROWSER_VERSION=latest
ENV ENGRAM_VERSION=${ENGRAM_VERSION} \
    SUPERPOWERS_REF=${SUPERPOWERS_REF} \
    UI_UX_PRO_MAX_REF=${UI_UX_PRO_MAX_REF} \
    IMPECCABLE_REF=${IMPECCABLE_REF} \
    PLAYWRIGHT_CLI_REF=${PLAYWRIGHT_CLI_REF} \
    AGENT_BROWSER_REF=${AGENT_BROWSER_REF} \
    PLAYWRIGHT_CLI_VERSION=${PLAYWRIGHT_CLI_VERSION} \
    PLAYWRIGHT_VERSION=${PLAYWRIGHT_VERSION} \
    PLAYWRIGHT_BROWSER_CHANNEL=${PLAYWRIGHT_BROWSER_CHANNEL} \
    AGENT_BROWSER_VERSION=${AGENT_BROWSER_VERSION} \
    PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1 \
    PLAYWRIGHT_CHROMIUM_EXECUTABLE_PATH=/usr/bin/chromium

COPY scripts/install-opencode-skills.sh /usr/local/bin/install-opencode-skills
COPY scripts/install-engram.sh /usr/local/bin/install-engram
COPY scripts/install-container-packages.sh /usr/local/bin/install-container-packages
COPY scripts/ensure-pnpm.sh /usr/local/bin/ensure-pnpm
COPY scripts/configure-opencode-engram.sh /usr/local/bin/configure-opencode-engram
COPY skills/frontend-ai-orchestrator /opt/opencode-custom-skills/frontend-ai-orchestrator
COPY skills/frontend-scaffold-intake /opt/opencode-custom-skills/frontend-scaffold-intake

RUN chmod +x \
    /usr/local/bin/install-opencode-skills \
    /usr/local/bin/install-engram \
    /usr/local/bin/install-container-packages \
    /usr/local/bin/ensure-pnpm \
    /usr/local/bin/configure-opencode-engram
RUN APK_EXTRA_PACKAGES=gcompat /usr/local/bin/install-container-packages bash ca-certificates curl git nodejs npm python3
RUN /usr/local/bin/ensure-pnpm
RUN LOCAL_SKILL_ROOT=/opt/opencode-custom-skills \
    OPENCODE_SKILLS_DIR=/root/.config/opencode/skills \
    INSTALL_PLAYWRIGHT_CLI=0 \
    INSTALL_AGENT_BROWSER_CLI=0 \
    INSTALL_PLAYWRIGHT_BROWSER=0 \
    /usr/local/bin/install-opencode-skills
RUN /usr/local/bin/install-engram \
    && engram setup opencode \
    && /usr/local/bin/configure-opencode-engram
RUN mkdir -p /opt/opencode-skills-seed /opt/opencode-plugins-seed /opt/opencode-config-seed \
    && cp -R /root/.config/opencode/skills/. /opt/opencode-skills-seed/ \
    && cp -R /root/.config/opencode/plugins/. /opt/opencode-plugins-seed/ \
    && cp /root/.config/opencode/opencode.json /opt/opencode-config-seed/opencode.json

FROM ${OPENCODE_IMAGE}

USER root

ARG SUPERPOWERS_REF=main
ARG UI_UX_PRO_MAX_REF=main
ARG IMPECCABLE_REF=main
ARG PLAYWRIGHT_CLI_REF=main
ARG AGENT_BROWSER_REF=main
ARG PLAYWRIGHT_CLI_VERSION=latest
ARG PLAYWRIGHT_VERSION=latest
ARG PLAYWRIGHT_BROWSER_CHANNEL=chromium
ARG AGENT_BROWSER_VERSION=latest
ARG RUN_SMOKE_CHECK=1

ENV SUPERPOWERS_REF=${SUPERPOWERS_REF} \
    UI_UX_PRO_MAX_REF=${UI_UX_PRO_MAX_REF} \
    IMPECCABLE_REF=${IMPECCABLE_REF} \
    PLAYWRIGHT_CLI_REF=${PLAYWRIGHT_CLI_REF} \
    AGENT_BROWSER_REF=${AGENT_BROWSER_REF} \
    PLAYWRIGHT_CLI_VERSION=${PLAYWRIGHT_CLI_VERSION} \
    PLAYWRIGHT_VERSION=${PLAYWRIGHT_VERSION} \
    PLAYWRIGHT_BROWSER_CHANNEL=${PLAYWRIGHT_BROWSER_CHANNEL} \
    AGENT_BROWSER_VERSION=${AGENT_BROWSER_VERSION} \
    PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1 \
    PLAYWRIGHT_CHROMIUM_EXECUTABLE_PATH=/usr/bin/chromium \
    AGENT_BROWSER_EXECUTABLE_PATH=/usr/bin/chromium \
    AGENT_BROWSER_ARGS=--no-sandbox,--disable-dev-shm-usage \
    ENGRAM_DATA_DIR=/root/.engram

COPY scripts/ensure-opencode-skills.sh /usr/local/bin/ensure-opencode-skills
COPY scripts/smoke-opencode-toolchain.sh /usr/local/bin/smoke-opencode-toolchain
COPY scripts/install-container-packages.sh /usr/local/bin/install-container-packages
COPY scripts/ensure-pnpm.sh /usr/local/bin/ensure-pnpm

RUN chmod +x \
    /usr/local/bin/ensure-opencode-skills \
    /usr/local/bin/smoke-opencode-toolchain \
    /usr/local/bin/install-container-packages \
    /usr/local/bin/ensure-pnpm
RUN APK_EXTRA_PACKAGES=gcompat /usr/local/bin/install-container-packages bash ca-certificates chromium curl git nodejs npm python3
RUN /usr/local/bin/ensure-pnpm

COPY --from=skills-builder /usr/local/bin/engram /usr/local/bin/engram
COPY --from=skills-builder /opt/opencode-skills-seed /opt/opencode-skills-seed
COPY --from=skills-builder /opt/opencode-plugins-seed /opt/opencode-plugins-seed
COPY --from=skills-builder /opt/opencode-config-seed/opencode.json /root/.config/opencode/opencode.json

RUN mkdir -p /root/.config/opencode/skills /root/.config/opencode/plugins /root/.engram \
    && cp -R /opt/opencode-skills-seed/. /root/.config/opencode/skills/ \
    && cp -R /opt/opencode-plugins-seed/. /root/.config/opencode/plugins/

RUN npm install -g "@playwright/cli@${PLAYWRIGHT_CLI_VERSION}" "playwright@${PLAYWRIGHT_VERSION}" "agent-browser@${AGENT_BROWSER_VERSION}" \
    && npm cache clean --force

RUN agent-browser close >/dev/null 2>&1 || true
RUN if [ "${RUN_SMOKE_CHECK}" = "1" ]; then smoke-opencode-toolchain; fi

ENV OPENCODE_SKILLS_DIR=/root/.config/opencode/skills
