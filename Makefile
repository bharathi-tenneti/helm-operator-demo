.DEFAULT_GOAL:=help
SHELL:=/bin/bash
NAMESPACE=helm-demo	

##@ Application

install: ## Install all resources (CR/CRD's, RBAC and Operator)
	@echo ....... Creating namespace ....... 
	- kubectl create namespace ${NAMESPACE}
	@echo ....... Applying CRDs and Operator .......
	- kubectl apply -f deploy/crds/cache.example.com_memcacheds_crd.yaml -n ${NAMESPACE}
	- kubectl apply -f deploy/crds/example.com_nginxes_crd.yaml -n ${NAMESPACE}
	- kubectl apply -f deploy/crds/charts.helm.k8s.io_mongodbs_crd.yaml -n ${NAMESPACE}

	@echo ....... Applying Rules and Service Account .......
	- kubectl apply -f deploy/role.yaml -n ${NAMESPACE}
	- kubectl apply -f deploy/role_binding.yaml  -n ${NAMESPACE}
	- kubectl apply -f deploy/service_account.yaml  -n ${NAMESPACE}
	@echo ....... Applying Operator .......
	- kubectl apply -f deploy/operator.yaml -n ${NAMESPACE}
	@echo ....... Creating the Operator Instances .......
	- kubectl apply -f deploy/crds/cache.example.com_v1alpha1_memcached_cr.yaml -n ${NAMESPACE}
	- kubectl apply -f deploy/crds/example.com_v1alpha1_nginx_cr.yaml -n ${NAMESPACE}
	- kubectl apply -f deploy/crds/charts.helm.k8s.io_v1alpha1_mongodb_cr.yaml -n ${NAMESPACE}


uninstall: ## Uninstall all that are performed in the $ make install
	@echo ....... Uninstalling .......
	@echo ....... Deleting CR and CRD.......
	- kubectl delete -f deploy/crds/cache.example.com_v1alpha1_memcached_cr.yaml -n ${NAMESPACE}
	- kubectl delete -f deploy/crds/cache.example.com_memcacheds_crd.yaml -n ${NAMESPACE}
	- kubectl delete -f deploy/crds/example.com_v1alpha1_nginx_cr.yaml
	- kubectl delete -f deploy/crds/example.com_nginxes_crd.yaml
	- kubectl delete -f deploy/crds/charts.helm.k8s.io_v1alpha1_mongodb_cr.yaml
	- kubectl delete -f deploy/crds/charts.helm.k8s.io_mongodbs_crd.yaml
	@echo ....... Deleting Rules and Service Account .......
	- kubectl delete -f deploy/role.yaml -n ${NAMESPACE}
	- kubectl delete -f deploy/role_binding.yaml -n ${NAMESPACE}
	- kubectl delete -f deploy/service_account.yaml -n ${NAMESPACE}
	@echo ....... Deleting Operator .......
	- kubectl delete -f deploy/operator.yaml -n ${NAMESPACE}
	@echo ....... Deleting namespace ${NAMESPACE}.......
	- kubectl delete namespace ${NAMESPACE}

.PHONY: help
help:  ## Display this help
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z0-9_-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)
