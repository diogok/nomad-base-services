nomad_version=0.10.0
consul_version=1.6.1
cni_version=0.8.2

os=$(shell uname -s | tr '[:upper:]' '[:lower:]')

arch=$(shell arch)

ifeq ($(arch),armv6l)
	arch=arm
endif

ifeq ($(arch),x86_64)
	arch=amd64
endif

start:
	consul agent -dev -client 0.0.0.0 > consul.log 2>&1 &
	sudo nomad agent -dev-connect > nomad.log 2>&1 &
	tail -f consul.log nomad.log

start-consul:
	consul agent -dev -client 0.0.0.0
	
start-nomad:
	sudo nomad agent -dev-connect -bind 0.0.0.0

install-consul:
	curl https://releases.hashicorp.com/consul/$(consul_version)/consul_$(consul_version)_$(os)_$(arch).zip -o consul_$(consul_version)_$(os)_$(arch).zip
	unzip consul_$(consul_version)_$(os)_$(arch).zip
	rm consul_$(consul_version)_$(os)_$(arch).zip
	chmod +x consul
	sudo mv consul /usr/local/bin/consul

install-nomad:
	curl https://releases.hashicorp.com/nomad/$(nomad_version)/nomad_$(nomad_version)_$(os)_$(arch).zip -o nomad_$(nomad_version)_$(os)_$(arch).zip
	unzip nomad_$(nomad_version)_$(os)_$(arch).zip
	rm nomad_$(nomad_version)_$(os)_$(arch).zip
	chmod +x nomad
	sudo mv nomad /usr/local/bin/nomad

install-cni:
	curl -L https://github.com/containernetworking/plugins/releases/download/v$(cni_version)/cni-plugins-$(os)-$(arch)-v$(cni_version).tgz -o cni_$(cni_version)_$(os)_$(arch).tgz
	sudo mkdir -p /opt/cni/bin
	sudo tar -C /opt/cni/bin -xzf cni_$(cni_version)_$(os)_$(arch).tgz
	rm cni_$(cni_version)_$(os)_$(arch).tgz

install: install-consul install-nomad install-cni
