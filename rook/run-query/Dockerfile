FROM uccross/skyhookdm-ceph:v14.2.9

RUN yum install -y wget

ADD entrypoint.sh /entrypoint.sh
ADD config/ceph.conf /etc/ceph/ceph.conf
ADD config/keyring /etc/ceph/keyring

WORKDIR /

ENTRYPOINT [ "/entrypoint.sh" ]
