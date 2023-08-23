# rnd-nginx-proxy-manager
* [How to start](#how-to-start)
* [How to add host](#how-to-add-host)
* [Troubleshooting](#troubleshooting)
  - [If you don't have NAT loopback configured by your ISP, i.e. you can't make request to domain pointing to your Public IP](#if-you-dont-have-nat-loopback-configured-by-your-isp-ie-you-cant-make-request-to-domain-pointing-to-your-public-ip)
    + [Option #1.](#option-%231)
    + [Option #2](#option-%232)
    + [Option #3](#option-%233)
  
Launch NPM locally as reverse-proxy for any domain referencing to your home ISP Public IP 

Platform: `Mac M1`

## How to start

1. NPM setup
   - install docker (optionally `colima`)
   - copy `project.env` from `project.env.dist` and set vars
   - `make up` - if you see permission errors, run 2 times more - it will create `./data` and `./letsencrypt` folders. Then it will launch successfully
2. Set subdomain(`npm.<your-domain>.com`) `A` record pointing to pure public IP of local server (XX.XX.XX.XX), not `alias`([portchecker](https://portchecker.co/) can help to check public IP and open ports)
3. Setup port forwarding for NginxProxyManager(NPM) on your router:
    - local server lan IP TCP, e.g. 192.168.0.111
    - `TCP/UDP 192.168.0.111 :80 → :80`
    - `TCP/UDP 192.168.0.111 :443 → :443`
4. Open NPM admin panel, use default creds to login to NPM
    - `localhost:4081`
    - `admin@example.com`
    - `changeme`

## How to add host
- Click on "Add proxy host"
    - **Domain name** - `sub.<your-domain>.com`
        - without `http`, `https`, or `port`
    - **Scheme** - `http` - it’s your local service access scheme
    - **Forward hostname** - if NPM not in the same docker-compose, put your local server LAN IP, e.g. `192.168.0.111`
    - **Forward port** - local service access port, e.g. `3000`
    - **Block common exploits** - `check`
    - **SSL**
        - **certificate** - generate for subdomain - `sub.<your-domain>.com`
        - you can generate it from the settings form or choose generated beofre from list
        - check `Force SSL`, `HSTS`, `HTTP/2 support`, `HSTS subdomains`
- Now you should be able to reach your local service from the web by `https://sub.<your-domain>.com` and your connection should be secure

## Troubleshooting

### If you don't have NAT loopback configured by your ISP, i.e. you can't make request to domain pointing to your Public IP 

#### Option #1. 
To access your reverse-proxy resource by domain name you need to access it from different internet connection (if your ISP doesn’t support NAT loopback)
- Open “New Private Window with Tor” (Brave)
- Connect via mobile hotspot from other device
- Use Android “HTTP shortcuts” app with mobile connection (disabled WiFi)
- 
#### Option #2 
Or you can you local domain forward by adding your domain and IP address to the `/etc/hosts` file. You may have to use sudo or editor.
```text
echo "127.0.0.1 sub.<your-domain>.com" >> /etc/hosts
dscacheutil -flushcache # Flush the DNS cache for the changes to take effect
```

#### Option #3
Use `dnsmasq`
- `brew install dnsmasq`
- To start dnsmasq now and restart at startup
  ```bash
  sudo brew services start dnsmasq
  ``` 
- Copy the default configuration file. And set your domain resolution to IP
  ```bash
  sudo mkdir -p /usr/local/etc && \
  sudo cp $(brew list dnsmasq | grep /dnsmasq.conf) /usr/local/etc/dnsmasq.conf
  echo 'address=/test.my-domain.com/127.0.0.1' > /usr/local/etc/dnsmasq.conf # editor may required to change file
  sudo brew services restart dnsmasq
  ```
- Go to System Settings → Network → Wi-Fi (or your selected active connection) → Advanced → DNS.
  Then, add `127.0.0.1` and `8.8.8.8` to your DNS Servers.
- Flush DNS cache: 
  ```bash
  sudo killall -HUP mDNSResponder
  ``` 
- ping your domain to check if it resolved locally:
  ```bash
  ping test.my-domain.com
  ``` 
