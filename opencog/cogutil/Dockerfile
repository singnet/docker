# Step to take
# 1. docker build --no-cache -t singularitynet/cogutil
# 2. docker run --rm -it singularitynet/cogutil

FROM singularitynet/opencog-deps

# Install cogutil
RUN  /tmp/octool -c ; ccache -C

USER opencog

# Docker defaults
CMD bash

# For images built on this
ONBUILD USER root
