output "gateway_private_ip" {
  value = aws_instance.wireguard.private_ip
}

output "gateway_private_dns" {
  value = aws_instance.wireguard.private_dns
}

output "gateway_public_dns" {
  value = aws_instance.wireguard.public_dns
}

output "gateway_public_ip" {
  value = aws_eip.wireguard.public_ip
}