# Terraform-Automation
Automated secrets management and infrastructure deployment

Setup Instructions
Connect to EC2 Instance

ssh -i filename.pem ubuntu@publicip

Install GPG and Vault
sudo apt update && sudo apt install -y gpg
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
gpg --no-default-keyring --keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg --fingerprint
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update
sudo apt install -y vault
Start Vault Server

vault server -dev -dev-listen-address="0.0.0.0:8200"

Configure Security Groups
Open port 8200 in the EC2 security group to allow inbound traffic.

Access Vault Web Interface
Navigate to http://publicip:8200 in your browser.

Configuration
Log in to Vault

Use the root token provided by Vault.
Set Up Vault for Terraform Integration

export VAULT_ADDR='http://publicip:8200'
vault secrets enable -path=secret kv-v2
vault kv put secret/test-secret foo=bar
vault policy write terraform - <<EOF
path "*" {
  capabilities = ["list", "read"]
}
path "secrets/data/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}
path "kv/data/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}
path "secret/data/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}
path "auth/token/create" {
  capabilities = ["create", "read", "update", "list"]
}
EOF
vault write auth/approle/role/terraform \
    secret_id_ttl=10m \
    token_num_uses=10 \
    token_ttl=20m \
    token_max_ttl=30m \
    secret_id_num_uses=40 \
    token_policies=terraform
vault read auth/approle/role/terraform/role-id
vault write -f auth/approle/role/terraform/secret-id

