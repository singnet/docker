# Step to take
# 1. docker build --no-cache -t synthillect/cogutil
# 2. docker run --rm -it synthillect/cogutil

FROM synthillect/opencog-deps

# Install repositories and dependencies
# FIXME: when octools auto-updates remove this.
ARG OCPKG_URL=https://raw.githubusercontent.com/singnet/ocpkg/master/ocpkg
ADD ${OCPKG_URL} /tmp/octool
ARG GITHUB_NAME="singnet"
ENV GITHUB_NAME ${GITHUB_NAME}
RUN chmod 755 /tmp/octool

# Install cogutil
RUN  /tmp/octool -c ; ccache -C

USER opencog

# Docker defaults
CMD bash

# For images built on this
ONBUILD USER root
