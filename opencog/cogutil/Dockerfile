# Step to take
# 1. docker build --no-cache -t synthillect/cogutil
# 2. docker run --rm -it synthillect/cogutil

FROM synthillect/opencog-deps

# Install repositories and dependencies
# FIXME: when octools auto-updates remove this.
ADD https://raw.githubusercontent.com/ntoxeg/ocpkg/master/ocpkg \
    /tmp/octool
RUN chmod 755 /tmp/octool

# Install cogutil
RUN  /tmp/octool -c ; ccache -C

USER opencog

# Docker defaults
CMD bash

# For images built on this
ONBUILD USER root
