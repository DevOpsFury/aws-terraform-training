Source: https://github.com/haf/vagrant-vault

# Vagrant Vault

A PoC repo – a single Vagrantfile to get a 3-node cluster with:

 - Consul
 - Consul UI
 - Consul Encryption
 - Consul-Template
 - Vault with Consul HA backend

Do

``` bash
vagrant up
```

# Quick start

```
vault server -dev
```

Open second terminal:
```
export VAULT_ADDR='http://127.0.0.1:8200'
vault status
```

Now you can interact with vault in in-memory data store

# Initialize Consul

On `vault-01` host:
```
consul agent -server -bootstrap-expect=1 -data-dir /var/lib/consul/data -bind=192.168.33.10 -enable-script-checks=true -config-dir=/etc/consul/server
```

On `vault-02` and `vault-03` start consul manually:
```
systemctl start consul
```

Check if cluster is up:
```
[root@vault-01 ~]# consul members
Node      Address             Status  Type    Build  Protocol  DC    Segment
vault-01  192.168.33.10:8301  alive   server  1.4.0  2         dev1  <all>
vault-02  192.168.33.20:8301  alive   server  1.4.0  2         dev1  <all>
vault-03  192.168.33.30:8301  alive   server  1.4.0  2         dev1  <all>

```

If it's a-ok, init vault on `vault-01` server:
```
[root@vault-01 ~]# vault init -tls-skip-verify
WARNING! The "vault init" command is deprecated. Please use "vault operator
init" instead. This command will be removed in Vault 1.1.

Unseal Key 1: sahg1Y48nQ4fAzfzCM6UN8d9RTB+uqJiu0/HsQxr+CDF
Unseal Key 2: tGk1p191YACXyhJ/SHjRjnGYw1zMLGapAuJ40zMX4qT7
Unseal Key 3: J/ZgUCosSnr2VRP803aBX+UMRK6lfQU2gmZ98yIFbxOu
Unseal Key 4: y6j8nwL/VHNwOgL80HFf89ztPEB06POetitLf6ndrL59
Unseal Key 5: 7TiRQ/F4An6wMrjX6k1Qe8VGUwyYpTawcXHdMkNg7aNH

Initial Root Token: s.7DGCNrZsF2gbIK9BMRLWymZp
```

Now unseal the vault (3 times):
```
[root@vault-01 ~]# vault unseal -tls-skip-verify
WARNING! The "vault unseal" command is deprecated. Please use "vault operator
unseal" instead. This command will be removed in Vault 1.1.

Unseal Key (will be hidden): 
Key                Value
---                -----
Seal Type          shamir
Initialized        true
Sealed             true
Total Shares       5
Threshold          3
Unseal Progress    1/3
Unseal Nonce       36bba3e0-8ac6-b2e6-80a3-cfe3cbd0202c
Version            1.0.0
HA Enabled         true
```


