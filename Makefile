MAIN_PLAYBOOK=./k3s.yml
IN_VENV=. ./.venv/bin/activate

configure: setup
	$(IN_VENV) && \
		ansible-playbook -i inventory/mysystem/hosts.ini $(MAIN_PLAYBOOK)

kubeconfig:
	$(IN_VENV) && \
		ansible-playbook -i inventory/mysystem/hosts.ini ./download_kubeconfig.yml

inventory/mysystem:
	cp -r ./inventory/example ./inventory/mysystem

setup: .venv/bin/ansible-playbook

.venv:
	python -m venv .venv

.venv/bin/ansible-playbook: .venv
	$(IN_VENV) && \
		pip install ansible

clean:
	rm -rf .venv
