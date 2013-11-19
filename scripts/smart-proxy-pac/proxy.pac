/* Creator: Stanislav German-Evtushenko (2012)
 * Contributor: add your name here
 */
 
function FindProxyForURL(url, host) {
 
// **********************************
// Define HOSTS and DESTINATIONS
// **********************************
 
// DESTINATIONS
        dst_direct  = "DIRECT";
        dst_proxy1  = "PROXY proxy1.company.lan:3128"; 
        dst_proxy2  = "PROXY proxy2.company.lan:8080";
        dst_default = "PROXY proxy3.company.lan:8080; PROXY proxy4.company.lan:8080";
 
// HOST_DEST array
        host_dest = [
                // Common
                ["*.company.lan",                       dst_direct],    // Matches "*.company.lan"
                ["*.subdom.company.com",                dst_direct],    // Matches "*.subdom.company.com"
                ["*.domain2.com",                       dst_proxy1],    // Matches "*.domain2.com"
                ["*.domain3.com",                       dst_proxy1],    // Matches "*.domain3.com"
 
                // *.company4.com matches (the order is important, "*.company4.com" have to be the last item)
                ["company4.com",                        dst_proxy2],    // Matches exactly "company4.com"
                ["conference.company4.com",             dst_proxy2],    // Matches exactly "conference.company4.com"
                ["*.visio.company4.com",                dst_default],   // Matches "*.visio.company4.com"
                ["*.dmz.company4.com",                  dst_proxy1],    // Matches "*.dmz.company4.com"
                ["*.company4.com",                      dst_direct],    // Matches "*.company4.com"
 
                // *.company5.com matches (the order is important, "*.company5.com" have to be the last item)
                ["company5.com",                        dst_proxy2],    // Matches exactly "company5.com"
                ["conference.company5.com",             dst_proxy2],    // Matches exactly "conference.company5.com"
                ["*.visio.company5.com",                dst_default],   // Matches "*.visio.company5.com"
                ["*.dmz.company5.com",                  dst_proxy1],    // Matches "*.dmz.company5.com"
                ["*.company5.com",                      dst_direct],    // Matches "*.company5.com"
        ];
 
 
// *******************************
// CORE (please do not modify)
// *******************************
 
//// Debug (if use Firefox press Ctrl+Shift+J)
//      alert("URL: " + url);
//      alert("HOST: " + host);
 
// FUNCTIONS
 
        function select_proxy(host,host_dest){
                for (index in host_dest)
                        if (shExpMatch(host,host_dest[index][0])) return host_dest[index][1];
                return false;
        }
 
// SELECT PROXY
 
        // Return proxy if host matches at least one record from the host_dest array
        if (proxy = select_proxy(host,host_dest)) return proxy;
 
// PLAIN HOST NAMES
 
        // HOST with no dots -> DIRECT
        if (isPlainHostName(host)) return "DIRECT";
 
// PRIVATE IP ADDRESSES
 
        // HOST contains only numbers AND HOST is private IP -> DIRECT
        if (host.match(/^[0-9.]+$/))
                if (isInNet(host, "10.0.0.0", "255.0.0.0") ||
                        isInNet(host, "172.16.0.0",  "255.240.0.0") ||
                        isInNet(host, "192.168.0.0", "255.255.0.0") ||
                        isInNet(host, "127.0.0.0", "255.255.255.0"))
                        return "DIRECT";
 
// *** Doesn't work without access to an external DNS and also could be slow ***
//// If IP address is internal or hostname resolves to internal IP, send direct.
//      resolved_ip = dnsResolve(host);
//      if (isInNet(resolved_ip, "10.0.0.0", "255.0.0.0") ||
//              isInNet(resolved_ip, "172.16.0.0",  "255.240.0.0") ||
//              isInNet(resolved_ip, "192.168.0.0", "255.255.0.0") ||
//              isInNet(resolved_ip, "127.0.0.0", "255.255.255.0"))
//              return "DIRECT";
// ***~Doesn't work without access to an external DNS and also could be slow ***
 
// Return default proxy
return dst_default;
 
}
