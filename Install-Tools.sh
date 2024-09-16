#Install tools
  curl -fsSL https://pkgs.tailscale.com/stable/debian/bullseye.noarmor.gpg | tee /usr/share/keyrings/tailscale-archive-keyring.gpg >/dev/null && curl -fsSL https://pkgs.tailscale.com/stable/debian/bullseye.tailscale-keyring.list | tee /etc/apt/sources.list.d/tailscale.list && apt update && apt -y install fzf tldr cmatrix iperf3 speedtest-cli stress s-tui nnn ncdu links2 telnet tailscale
#Enable device as a subnet router
  echo 'net.ipv4.ip_forward = 1' | tee -a /etc/sysctl.d/99-tailscale.conf && echo 'net.ipv6.conf.all.forwarding = 1' | tee -a /etc/sysctl.d/99-tailscale.conf && sysctl -p /etc/sysctl.d/99-tailscale.conf
#Advertise subnet routes
  tailscale up --advertise-routes=192.0.2.0/24,198.51.100.0/24
