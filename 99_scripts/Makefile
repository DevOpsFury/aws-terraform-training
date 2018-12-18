VENV_BIN                 := venv/bin
PATH                     := $(VENV_BIN):$(PATH)

venv:
	@sudo apt-get -y gcc python3-dev python3-venv
	@python3 -m venv venv
	@$(VENV_BIN)/pip install -U psutil


eatcpu:
	@python3 ./eatcpu.py

eatmem: venv
	@python3 ./eatmem.py

.PHONY: venv eatcpu eatmem 
