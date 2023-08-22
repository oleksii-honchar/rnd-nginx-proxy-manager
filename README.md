# rnd-nginx-proxy-manager
Launch NPM locally as reverse-proxy for any domain referencing to your home ISP Public IP 

Platform: `Mac M1`

## How to start

1. NPM setup
   - install docker (optionally `colima`)
   - copy `project.env` from `project.env.dist` and set vars
   - `make up` - if you see permission errors, run 2 times more - it will create `./data` and `./letsencrypt` folders. Then it will launch successfully
2. Set AWS subdomain(`npm.<your-domain>.com`) `A` record pointing to pure public IP of local server (XX.XX.XX.XX), not `alias`([portchecker](https://portchecker.co/) can help to check public IP and open ports)
3. Setup port forwarding for NginxProxyManager(NPM) on your router:
    - local server lan IP TCP, e.g. 192.168.0.111
    - `TCP 192.168.0.111 :4080 → :80`
    - `TCP 192.168.0.111 :4443 → :443`
4. Open NPM admin panel, use default creds to login to NPM
    - `localhost:4081`
    - admin@example.com
    - changeme

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
- To access your reverse-proxy resource by domain name you need to access it from different internet connection (if your ISP doesn’t support NAT loopback)
    - Open “New Private Window with Tor” (Brave)
    - Connect via mobile hotspot from other device
    - Use Android “HTTP shortcuts” app with mobile connection (disabled WiFi)
- Now you should be able to reach your local service from the web by `https://sub.<your-domain>.com` and your connection should be secure