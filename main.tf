provider "aws" {
    region = "us-east-2"
  
}
provider "vault"{
    address = "http://18.188.207.254:8200"
  skip_child_token = true

  auth_login {
    path = "auth/approle/login"

    parameters = {
      role_id = "01fc0993-ab5b-89f3-e6db-0b9b3d571b77"
      secret_id = "9f650059-5f97-7c9a-5414-5c26572e1ae1"
    }
  }

}
data "vault_kv_secret_v2" "example" {
  mount = "kv"
  name  = "test-secret"
}
resource "aws_instance" "my_instance" {
  ami           = "ami-0862be96e41dcbf74"
  instance_type = "t2.micro"

  tags = {
        Secret = data.vault_kv_secret_v2.example.data["username"]
  }
}