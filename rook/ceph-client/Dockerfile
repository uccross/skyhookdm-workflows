FROM ubuntu:xenial

RUN apt-get update && \
    apt-get install -y ceph-common && \
    apt-get clean

ADD entrypoint.sh /entrypoint.sh
ADD config/ceph.conf /etc/ceph/ceph.conf
ADD config/keyring /etc/ceph/keyring

WORKDIR /

ENTRYPOINT [ "/entrypoint.sh" ]
