FROM debian:buster as base

RUN apt-get update
RUN apt-get install -y cmake pkg-config build-essential git devscripts fakeroot wget unzip tar

RUN dpkg --add-architecture armhf
RUN dpkg --add-architecture arm64
RUN apt-get update
RUN apt-get install -y crossbuild-essential-armhf crossbuild-essential-arm64

FROM base AS grpc

WORKDIR /app

RUN git clone --recurse-submodules https://github.com/emrahayanoglu/grpc.git

FROM grpc AS grpc-build

WORKDIR /app/grpc

RUN git checkout debian-support

RUN apt-get -o Debug::pkgProblemResolver=yes -y --force-yes build-dep .
RUN debuild -us -uc

RUN git reset --hard

WORKDIR /app
RUN dpkg -i grpc_1.52.1_amd64.deb

WORKDIR /app/grpc

RUN apt-get -o Debug::pkgProblemResolver=yes -y --force-yes build-dep -aarmhf .
RUN debuild -us -uc -aarmhf

RUN git reset --hard

RUN apt-get -o Debug::pkgProblemResolver=yes -y --force-yes build-dep -aarm64 .
RUN debuild -us -uc -aarm64

WORKDIR /app
RUN mkdir -p build
RUN cp *.deb build/