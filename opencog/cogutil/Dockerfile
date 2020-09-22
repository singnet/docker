# Step to take
# 1. docker build --no-cache -t singnet/cogutil
# 2. docker run --rm -it singnet/cogutil

FROM singnet/opencog-deps

# Install cogutil
RUN  /tmp/octool -c ; ccache -C

USER opencog

# Docker defaults
CMD bash

# For images built on this
ONBUILD USER root
