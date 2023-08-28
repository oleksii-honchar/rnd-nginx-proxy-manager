# rnd-nginx-proxy-manager

- [Motivation](#motivation)
- [How to start](#how-to-start)
- [How to add host](#how-to-add-host)
- [Troubleshooting](#troubleshooting)
    * [If you don't have NAT loopback configured by your ISP, i.e. you can't make request to domain pointing to your Public IP](#no-nat-loopback)
        + [Option #1 - when you don't need to access domain locally frequently - use Brave Tor](#option-1)
        + [Option #2 - when few hosts in local network need access - update /etc/hosts](#option-2)
        + [Option #3 - when Wi-Fi hosts or many hosts need acces via domain name - use dnsmasq + squid](#option-3)
            - [Setup `dnsmasq`](#setup-dnsmasq)
            - [Setup `squid`](#setup-squid)
        + [Option #4 - let's make everything in docker without sudo](#option-4)  

## Motivation

- Launch NPM locally as reverse-proxy for any domain referencing to your home ISP Public IP
- With minimal system footprint and manual effort

Platform: `Mac M1`

## How to start

1. NPM setup
   - install docker (optionally `colima`)
   - copy `project.env` from `project.env.dist` and set vars
   - `make up svc=nginx_proxy_manager` - if you see permission errors, run 2 times more - it will create `./data` and `./letsencrypt` folders. Then it will launch successfully
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

<a name="no-nat-loopback"></a>
### If you don't have NAT loopback configured by your ISP  

I.e. you can't make request to domain pointing to your Public IP from your local network.

Recommended option is [Option #4](#option-4) since it already configured, require minimum effort and leave minimum system footprint.

Other options listed for educational purposes.

<a name="option-1"></a>
#### Option #1 - when you don't need to access domain locally frequently - use Brave Tor

<details>

<summary>expand</summary>

To access your reverse-proxy resource by domain name you need to access it from different internet connection (if your ISP doesn’t support NAT loopback)
- Open “New Private Window with Tor” (Brave)
- Connect via mobile hotspot from other device
- Use Android “HTTP shortcuts” app with mobile connection (disabled WiFi)

</details>

<a name="option-2"></a>
#### Option #2 - when few hosts in local network need access - update /etc/hosts

<details>
<summary>expand</summary>

Or you can you local domain forward by adding your domain and IP address to the `/etc/hosts` file. You may have to use sudo or editor.
```text
echo "127.0.0.1 sub.<your-domain>.com" >> /etc/hosts
dscacheutil -flushcache # Flush the DNS cache for the changes to take effect
```

</details>

<a name="option-3"></a>
#### Option #3 - when Wi-Fi hosts or many hosts need acces via domain name - use dnsmasq + squid

<details>
<summary>expand</summary>

##### Setup `dnsmasq`
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

##### Setup `squid`

The thing is, that your local network wi-fi mobiles still not able to resolve your domain locally (because only rooted Android allowed to change `/etc/hosts`). So, let's try local web proxy then with `squid` & `dnsmasq`

- When dnsmasq installed
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
```bash
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
- Now go to your mobile, open "WiFi settings" -> Proxy -> manual -> 
  - set IP : `192.168.0.??` (set your squid server ip)
  - set port: `3128`
- Check your domain `test.my-domain.com` from mobile browser, now it should be resolved via squid -> dnsmasq -> npm -> your local server!!!
**Note:**
- By doing this all DNS & HTTP traffic from mobile clients browser (with configured proxy) and local DNS requests will go through `dnsmasq` and `squid`.

</details>

<a name="option-4"></a>
#### Option #4 - let's make everything in docker without sudo

- make copy of `project.env.dist` -> `project.env`
- define all the values
- copy/paste `.dist` templates to create `*.conf` files. Update following config files with proper values:
  - `dnsmasq/dnsmasq.conf`
  - `squid/squid.conf`
- start all services
```bash
make restart
```