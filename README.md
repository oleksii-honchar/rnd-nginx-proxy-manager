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
  edit /opt/homebrew/etc/dnsmasq.conf
  # add "address=/test.my-domain.com/127.0.0.1"
  # uncomment for logging "log-queries"
  # add "log-facility=/var/log/dnsmasq.log"
  # add server "server=8.8.8.8"
  # uncomment and add "listen-address=127.0.0.1"
  sudo brew services restart dnsmasq
  ```
- Go to System Settings → Network → Wi-Fi (or your selected active connection) → Advanced → DNS.
  Then, add `127.0.0.1` to your DNS Servers.
- Flush DNS cache: 
  ```bash
  sudo killall -HUP mDNSResponder
  ``` 
- ping your domain to check if it resolved locally:
  ```bash
  ping test.my-domain.com
  ``` 
  
**Notes:**
- test resolution 
  ```bash
  dig example.dev
  nslookup example.dev
  ping example.com
  ```

#### Option 4
The thing is, that your local network wi-fi mobiles still not able to resolve your domain locally (because only rooted Android allowed to change `/etc/hosts`). So, let's try local web proxy then with `squid` & `dnsmasq`

- Install `dnsmasq` following [Option #3](#option-3) instructions
- Add to dnsmasq config 
  - `edit /opt/homebrew/etc/dnsmasq.conf`
  - dhcp-option=252,”http://127.0.0.1:3128/wpad.dat”
- Now let's setup `squid`
```bash
brew install squid
cp /opt/homebrew/etc/squid.conf /opt/homebrew/etc/squid.conf.back
edit /opt/homebrew/etc/squid.conf
```
- Replace config with the following allow-all simple config:
```text
# Squid normally listens to port 3128
http_port 3128

# We setup an ACL that matches all IP addresses
acl all src all

# We allow all of our clients to browse the Internet
http_access allow all

# We strongly recommend the following be uncommented to protect innocent
# web applications running on the proxy server who think the only
# one who can access services on "localhost" is a local user
#http_access deny to_localhost
```
- `squid -z` to check conf
- `sudo brew services restart dnsmasq`
- `brew services restart squid` - non-root!
- check logs
  - log file `/opt/homebrew/var/logs/cache.log`
  - access log `/opt/homebrew/var/logs/access.log`
- Now go to your mobile, open "Wifi settings" -> Proxy -> manual -> 
  - set IP : `192.168.0.??` (set your squid server ip)
  - set port: `3128`
- Check your domain `test.my-domain.com` from mobile browser, now it should be resolved via squid -> dnsmasq -> npm -> your local server!!!
**Note:**
- By doing this all DNS & HTTP traffic from mobile clients browser (with configured proxy) and local DNS requests will go through `dnsmasq` and `squid`.


#### Option 4.1 (no ARM64 images for Squid nad DNSmasq :( )
So, let's try local web proxy then with `squid` & `dnsmasq` and `docker-compose`

- dnsmasq.conf:
    - listen-address=0.0.0.0
    - address=/test.my-domain.com/127.0.0.1
    - log-queries
    - server=8.8.8.8
- squid.conf
    - http_port 3128
      cache deny all
      visible_hostname localhost