#!/usr/bin/env python3
# -*- coding: utf-8 -*-













import os
import socket
import sys

EGRESS_TARGET = ("8.8.8.8", 53)
FORMAT = "hello xiangshan, I am %s, IP address %s"


def team_id():
    v = os.environ.get("TEAM_ID")
    return v if v else "TEAM_ID_UNSET"


def egress_ipv4():

    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    try:
        s.settimeout(2.0)
        s.connect(EGRESS_TARGET)
        ip = s.getsockname()[0]
        if ip and not ip.startswith("127."):
            return ip
        return None
    except OSError:
        return None
    finally:
        s.close()


def name_resolved_ipv4():

    try:
        infos = socket.getaddrinfo(socket.gethostname(), None, socket.AF_INET)
    except OSError:
        return None
    for ai in infos:
        ip = ai[4][0]
        if ip and not ip.startswith("127.") and not ip.startswith("169.254."):
            return ip
    return None


def main():
    method = "udp_egress_no_packets_sent"
    ip = egress_ipv4()
    if ip is None:
        method = "getaddrinfo_fallback"
        ip = name_resolved_ipv4()
    if ip is None:
        method = "no_local_ipv4"
        ip = "unavailable"
    out = sys.stdout
    out.write(FORMAT % (team_id(), ip) + "\n")
    out.write("ip_selection_method=%s\n" % method)
    out.write("host=%s python=%s platform=%s\n"
              % (socket.gethostname(), sys.version.split()[0], sys.platform))
    out.write("HELLO_ANYOS ip=%s\n" % ip)
    return 0 if ip != "unavailable" else 3


if __name__ == "__main__":
    sys.exit(main())
