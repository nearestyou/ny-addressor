FROM ubuntu:22.04

ENV LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    DEBIAN_FRONTEND=noninteractive

# 🧰 Install system deps, build tools, and Ruby
RUN apt-get update && apt-get install -y \
  git autoconf automake libtool pkg-config curl build-essential ruby-full \
  && rm -rf /var/lib/apt/lists/*

# 🏗️ Build and install libpostal
RUN git clone https://github.com/openvenues/libpostal /tmp/libpostal \
  && cd /tmp/libpostal \
  && ./bootstrap.sh \
  && ./configure --prefix=/usr/local \
  && make -j$(nproc) \
  && make install \
  && echo "/usr/local/lib" > /etc/ld.so.conf.d/libpostal.conf \
  && ldconfig \
  && rm -rf /tmp/libpostal

WORKDIR /app

COPY . .

# 📦 Install Ruby gems
RUN gem install bundler && bundle install


CMD ["/bin/bash"]
