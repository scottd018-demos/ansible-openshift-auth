setup:
	virtualenv venv && \
		source venv/bin/activate && \
		pip install --no-cache-dir -r requirements.txt

demo:
	source venv/bin/activate && \
	ansible-playbook main.yaml --ask-vault-pass