VENV_BIN                 := venv/bin
PATH                     := $(VENV_BIN):$(PATH)

venv:
	@python3 -m venv venv
	@$(VENV_BIN)/pip install -U -r requirements.txt

create-package:
	@cd venv/lib/python3.6/site-packages
	@zip -r9 ../../../../lambda-package.zip .
	@cd ../../../..
	@zip -g lambda-package.zip LambdaFunction.py

deploy-lambda:
	@aws lambda create-function \
		--region eu-central-1 \
		--function-name some-lambda-function \
		--zip-file fileb://lambda-package.zip \
		--handler LambdaFunction.handler \
		--runtime python3.6 \
		--role arn:aws:iam::$(shell echo $(AWS_ACCOUNT_ID)):role/lambda_basic_execution

.PHONY: venv create-package deploy-lambda
