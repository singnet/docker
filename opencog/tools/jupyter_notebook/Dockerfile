# For interacting with jupter notebooks. This installs a kernel for python and guile.

# Build from opencog-dev:cli as it has all packages it needs.
FROM synthillect/opencog-dev:cli

RUN apt-get update --fix-missing && apt-get install -y wget bzip2 ca-certificates \
    libglib2.0-0 libxext6 libsm6 libxrender1 \
    git mercurial subversion \
    curl python3-pip

RUN python3 -m pip install jupyterlab ipykernel tornado

# Install guile-json as it is needed for guile-kernel
WORKDIR /opt/

RUN wget https://download.savannah.gnu.org/releases/guile-json/guile-json-0.6.0.tar.gz && \
    tar xvf guile-json-0.6.0.tar.gz && \
    rm guile-json-0.6.0.tar.gz && \
    cd guile-json-0.6.0 && \
    ./configure && \
    make install
# Why does it install in the wrong directory?
# RUN mkdir -p /usr/local/share/guile/site/2.2/
RUN mv /usr/local/share/guile/site/json* /usr/share/guile/site/2.2/

# ZMQ library to enable communication with jupyter notebook
RUN wget https://raw.githubusercontent.com/jerry40/guile-simple-zmq/master/src/simple-zmq.scm -O /usr/share/guile/site/2.2/simple-zmq.scm

# Create a directory with the guile kernel in jupyter notebook kernels directory
WORKDIR /usr/local/share/jupyter/kernels

RUN git clone --depth 1 https://github.com/jerry40/guile-kernel
# Copy kernel description to the above folder
COPY kernel.json /usr/local/share/jupyter/kernels/guile-kernel

EXPOSE 8888
USER opencog
CMD [ "jupyter", "lab", "--ip=0.0.0.0", "--port=8888", "--no-browser" ]
