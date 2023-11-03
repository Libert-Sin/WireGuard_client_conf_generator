#!/usr/bin/env ruby


require 'fileutils'


client_name = ARGV[0]
num = ARGV[1]


wg_dir = "/etc/wireguard"
wg_interface = "wg0" 
wg_server_config = "#{wg_dir}/#{wg_interface}.conf"
wg_client_config = "#{wg_dir}/#{client_name}.conf"

server_public_key = "서버 공개키"
server_endpoint = "서버의 도메인 또는 아이피:포트"

# 필요할 경우 수정 필요
client_vpn_ip = "10.0.0.#{num}" 
client_dns = "1.1.1.1, 1.0.0.1"


unless system('which wg')
  STDERR.puts 'Error: WireGuard is not installed.'
  exit 1
end


# 클라이언트 개인키와 공개키 생성
FileUtils.mkdir_p(wg_dir) unless Dir.exist?(wg_dir)
File.umask(0077)
private_key_path = "#{wg_dir}/#{client_name}_private.key"
public_key_path = "#{wg_dir}/#{client_name}_public.key"

private_key = `wg genkey`.strip
File.write(private_key_path, private_key)
public_key = `echo #{private_key} | wg pubkey`.strip
File.write(public_key_path, public_key)


# 클라이언트 설정 파일 생성
File.open(wg_client_config, 'w') do |file|
  file.puts "[Interface]"
  file.puts "PrivateKey = #{private_key}"
  file.puts "Address = #{client_vpn_ip}/32"
  file.puts "DNS = #{client_dns}"
  file.puts ""
  file.puts "[Peer]"
  file.puts "PublicKey = #{server_public_key}"
  file.puts "Endpoint = #{server_endpoint}"
  file.puts "AllowedIPs = 0.0.0.0/0, ::/0"
  file.puts "PersistentKeepalive = 25"
end


# 서버 설정 파일에 클라이언트 정보 추가
open(wg_server_config, 'a') do |file|
  file.puts ""
  file.puts "# 클라이언트: #{client_name}"
  file.puts "[Peer]"
  file.puts "PublicKey = #{public_key}"
  file.puts "AllowedIPs = #{client_vpn_ip}/32"
end


# WireGuard 서비스 재시작
system("bash -c 'wg syncconf #{wg_interface} <(wg-quick strip #{wg_interface})'")


# 설정 파일의 QR 코드 생성
system("qrencode -t ansiutf8 < #{wg_client_config}")


# 스크립트 완료 메시지
puts "클라이언트 설정 파일 생성 완료: #{wg_client_config}"
