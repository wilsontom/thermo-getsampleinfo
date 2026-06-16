FROM rocker/r-ver:4.4.3

ARG DEBIAN_FRONTEND=noninteractive
ARG GETSAMPLEINFO_REF=master

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        git \
        mono-mcs \
        mono-runtime \
    && rm -rf /var/lib/apt/lists/*

RUN Rscript -e "install.packages(c('tibble', 'stringr', 'purrr'), repos = 'https://cloud.r-project.org')"

RUN git clone --depth 1 https://github.com/wilsontom/GetSampleInfo.git /tmp/GetSampleInfo \
    && cd /tmp/GetSampleInfo \
    && git fetch --depth 1 origin "${GETSAMPLEINFO_REF}" \
    && git checkout FETCH_HEAD \
    && THERMO_RAWFILEREADER_HOME= R CMD INSTALL . \
    && rm -rf /tmp/GetSampleInfo

ENV THERMO_RAWFILEREADER_HOME=/opt/RawFileReader

RUN printf '%s\n' \
    '#!/bin/sh' \
    'set -e' \
    'pkg_dir="$(Rscript -e "cat(system.file(package = '\''GetSampleInfo'\''))")"' \
    'exe_dir="$pkg_dir/bin/RawFileReader"' \
    'if [ -d "${THERMO_RAWFILEREADER_HOME:-}" ] && [ ! -f "$exe_dir/GetSampleInfo.exe" ]; then' \
    '  THERMO_RAWFILEREADER_HOME="$THERMO_RAWFILEREADER_HOME" bash "$pkg_dir/compile.sh"' \
    'fi' \
    'exec "$@"' \
    > /usr/local/bin/docker-entrypoint \
    && chmod +x /usr/local/bin/docker-entrypoint

ENTRYPOINT ["docker-entrypoint"]
CMD ["R"]
