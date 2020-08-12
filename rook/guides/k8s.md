# Setting up a Kubernetes cluster on an internal network

This guide walks you through the process of setting up a Kubernetes cluster on an internal high-speed network
or on a network interface different from the default.

## Master Node

1. Install `kubeadm`, `kubelet`, `kubectl` on the master.
```bash
# install prerequisites
sudo apt-get update
sudo apt-get install -y software-properties-common

# install kubeadm and kubectl
curl -o- https://get.docker.com | bash
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
cat << EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl

# switch off the swap
sudo apt-mark hold kubelet kubeadm kubectl
sudo swapoff -a
```

2. Configure and restart `kubelet` to listen on the internal network IP, like `10.10.1.1` in this case. Run the commands as `sudo`.
```bash
# change the node-ip and restart kubelet
echo "Environment=\"KUBELET_EXTRA_ARGS=--node-ip=10.10.1.1\"" >> /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
systemctl daemon-reload
systemctl restart kubelet
```

3. Initialize the master using the following command.
```bash
sudo kubeadm init --pod-network-cidr=10.244.0.0/16 --apiserver-advertise-address=10.10.1.1 >> join.txt
# the join command for the worker nodes is generated in the join.txt file
```

4. Copy the kubernetes config to the defacto `.kube` dir to configure `kubectl` and apply calico networking.
```bash
# copy the k8s config to $HOME/.kube for kubectl to find
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# apply calico networking
kubectl apply -f https://docs.projectcalico.org/v3.9/manifests/calico.yaml

# check the master node
kubectl get nodes -o wide
```

5. Install kubestone on the cluster.
```bash
# download and install kustomize
curl -s "https://raw.githubusercontent.com/\
kubernetes-sigs/kustomize/master/hack/install_kustomize.sh"  | bash
sudo cp ./kustomize /usr/local/bin

# install the kubestone operator 
git clone https://github.com/xridge/kubestone
cd kubestone/config/default
kustomize build | kubectl create -f -

# make a namespace called kubestone
kubectl create ns kubestone
```

6. If you want kubernetes to schedule pods on the master also, do 
```bash
kubectl taint nodes --all node-role.kubernetes.io/master-
```

## Worker nodes

1. Install `kubeadm`, `kubelet`, `kubectl` on the worker.
```bash
sudo apt-get update
sudo apt-get install -y software-properties-common

curl -o- https://get.docker.com | bash
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
cat << EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl

sudo apt-mark hold kubelet kubeadm kubectl
sudo swapoff -a
```

2. Configure and restart `kubelet` to listen on the internal network IP, like `10.10.1.2` in this case. Run the commands as `sudo`.
```bash
# change the node-ip and restart kubelet
echo "Environment=\"KUBELET_EXTRA_ARGS=--node-ip=10.10.1.2\"" >> /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
systemctl daemon-reload
systemctl restart kubelet
```

3. Run the `kubeadm join` command generated in the `join.txt` file in the master node as `sudo` to add the worker node to the cluster.


Following the above steps should setup the cluster to use the specified network for communication.