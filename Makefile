nomad_version=0.9.1
consul_version=1.5.0
levant_version=0.2.7

os=$(shell uname -s | tr '[:upper:]' '[:lower:]')

arch=$(shell arch)

ifeq ($(arch),armv6l)
	arch=arm
endif

ifeq ($(arch),x86_64)
	arch=amd64
endif

start:
	bin/consul agent -dev -client 0.0.0.0 > consul.log 2>&1 &
	bin/nomad agent -dev > nomad.log 2>&1 &
	bin/weave launch --no-restart --ipalloc-range 10.2.3.0/24 | true
	bin/weave expose -h host.weave.local
	bin/scope launch | true
	tail -f consul.log nomad.log

deploy:
	./bin/levant deploy --force-count --ignore-no-changes $(JOB)

deploy-all: 
	./bin/levant deploy --force-count --ignore-no-changes services/elasticsearch.nomad
	ls services/*.nomad | xargs -n1 ./bin/levant deploy --force-count --ignore-no-changes

install-network:
	docker network create --subnet 10.2.2.0/24 --gateway 10.2.2.1 network || true

install-consul:
	curl https://releases.hashicorp.com/consul/$(consul_version)/consul_$(consul_version)_$(os)_$(arch).zip -o consul_$(consul_version)_$(os)_$(arch).zip
	unzip consul_$(consul_version)_$(os)_$(arch).zip
	rm consul_$(consul_version)_$(os)_$(arch).zip
	chmod +x consul
	mkdir -p bin
	mv consul bin/consul

install-nomad:
	curl https://releases.hashicorp.com/nomad/$(nomad_version)/nomad_$(nomad_version)_$(os)_$(arch).zip -o nomad_$(nomad_version)_$(os)_$(arch).zip
	unzip nomad_$(nomad_version)_$(os)_$(arch).zip
	rm nomad_$(nomad_version)_$(os)_$(arch).zip
	chmod +x nomad
	mkdir -p bin
	mv nomad bin/nomad

install-levant:
	mkdir -p bin
	curl -L https://github.com/jrasell/levant/releases/download/$(levant_version)/$(os)-$(arch)-levant -o bin/levant
	chmod +x bin/levant

install-weave:
	curl -L git.io/weave -o ./bin/weave
	chmod +x bin/weave
	curl -L git.io/scope -o ./bin/scope
	chmod +x bin/scope

install: install-consul install-nomad install-levant install-network install-weave
