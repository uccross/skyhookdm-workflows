FROM jcnitdgp25/skyhookdm-ceph:v14.2.9

ADD entrypoint.sh /entrypoint.sh

WORKDIR /

ADD config/ceph.conf /etc/ceph/ceph.conf
ADD config/keyring /etc/ceph/keyring

RUN yum install -y wget

ENTRYPOINT [ "/entrypoint.sh" ]
