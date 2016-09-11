# DHCP address reservation

In order to enable address reservation for selected hosts in your network, use `--dhcp-hosts <file_path>` option with a path to an address reservation file.

The file should contain address reservation entries, one per line, compatible with the `dnsmasq` dhcp-host configuration option, with the exception that commas can be replaced with multiple spaces or tabs for nicer formatting.

Also comments are supported either on independent lines or appended to the entry lines.

This feature should typically be used in combination with `-g` option to make sure that the assigned addresses in the configuration file are on the same network as the gateway.

Example configuration is presented below:

```
#
# Laptops
#
00:1C:F0:A8:0A:11       192.168.1.101               # Alice's laptop
00:26:BB:12:CC:22       192.168.1.102   infinite    # Bob's laptop (infite lease)
00:26:BB:12:CC:33       192.168.1.103               # Jenny's laptop

#
# Mobiles
#
90:F6:52:06:65:44       192.168.1.104               # Alice's mobile
80:1F:02:59:64:55       192.168.1.105               # Bob's mobile

#
# Other
#
C4:85:08:F3:A4:66       ignore                      # Disable DHCP for desktop
```

which produces the following entries in the `dnsmasq.conf`:

```
dhcp-host=00:1C:F0:A8:0A:11,192.168.1.101
dhcp-host=00:26:BB:12:CC:22,192.168.1.102,infinite
dhcp-host=00:26:BB:12:CC:33,192.168.1.103
dhcp-host=90:F6:52:06:65:44,192.168.1.104
dhcp-host=80:1F:02:59:64:55,192.168.1.105
dhcp-host=C4:85:08:F3:A4:66,ignore
```

For more `dhcp-host` entry format checkout `dnsmasq` [manpage](http://www.thekelleys.org.uk/dnsmasq/docs/dnsmasq-man.html).