FROM alpine:3.13.0 AS build
# crypto++-dev is in edge/testing
RUN apk add --no-cache --repository http://dl-3.alpinelinux.org/alpine/edge/testing/ \
  binutils \
  boost-dev \
  build-base \
  clang \
  cmake \
  crypto++-dev \
  fmt-dev \
  gcc \
  gmp-dev \
  luajit-dev \
  make \git
  mariadb-connector-c-dev \
  pugixml-dev

COPY cmake /usr/src/the-realempire-server/cmake/
COPY src /usr/src/the-realempire-server/src/
COPY CMakeLists.txt /usr/src/the-realempire-server/
WORKDIR /usr/src/the-realempire-server/build
RUN cmake .. && make

FROM alpine:3.13.0
# crypto++ is in edge/testing
RUN apk add --no-cache --repository http://dl-3.alpinelinux.org/alpine/edge/testing/ \
  boost-iostreams \
  boost-system \
  boost-filesystem \
  crypto++ \
  fmt \
  gmp \
  luajit \
  mariadb-connector-c \
  pugixml

COPY --from=build /usr/src/the-realempire-server/build/tfs /bin/tfs
COPY data /srv/data/
COPY LICENSE README.md *.dist *.sql key.pem /srv/

EXPOSE 7171 7172
WORKDIR /srv
VOLUME /srv
ENTRYPOINT ["/bin/tfs"]
