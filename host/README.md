# Host-level maintenance scripts for ce-services.phy.syr.edu

Things that live on the CentOS 8 host itself rather than in a container.

## upgrade-openssh.sh

The host's packaged OpenSSH 8.0 is frozen (CentOS 8 is end-of-life), so sshd
is built from source into `/usr/local` and started by a systemd drop-in
(`ExecStart=/usr/local/sbin/sshd -D -f /etc/ssh/sshd_config`). Each new
OpenSSH release gets flagged by the campus Nessus scans; this script performs
the upgrade safely: download and verify the release signature, build with the
same configure options as the original May 2026 build, start the new daemon
on port 2222 against the live configuration and check its banner, then
install, test the configuration with the new binary and restart the service.
Keep an SSH session open while running it; existing sessions survive the
restart.

```sh
/root/ce-it-infrastructure/host/upgrade-openssh.sh 10.4p1
```

`VERIFY_ONLY=1` stops after the signature check, `BUILD_ONLY=1` after the
port-2222 test. Logs land in `/root/ssh/openssh-<version>.{configure,make,install}.log`.

Releases sometimes need a fix that is already upstream but not yet in a
tarball; put it in `host/patches/openssh-<version>-*.patch` and the script
applies it after extraction. 10.4p1 ships with its GSSAPI keywords misnamed
(`sshd -t` rejects `GSSAPIAuthentication`; upstream bz3974), so
`openssh-10.4p1-gssapi-option-names.patch` is upstream commit c147093.

## ssh-firewall.sh / ssh-firewall.service

Restricts SSH (tcp/22) to the campus network 128.230.0.0/16, the VPN
10.57.0.0/16 and loopback; everything else, and all IPv6 except `::1`, is
dropped after a rate-limited `ssh-blocked:` line in `/var/log/messages`.
Implemented as an iptables chain `SSH-ACCESS` jumped to from the top of
INPUT, which Docker's own iptables management never touches. Established
sessions are always accepted, so applying it never cuts the session running
it. The service re-applies the rules at boot (before sshd).

```sh
install -m 755 host/ssh-firewall.sh /usr/local/sbin/
install -m 644 host/ssh-firewall.service /etc/systemd/system/
systemctl daemon-reload && systemctl enable --now ssh-firewall.service
ssh-firewall.sh status      # counters per rule
ssh-firewall.sh remove      # open port 22 again (or systemctl stop ssh-firewall)
```

Containers cannot reach the host's sshd either (their bridge addresses are
not in the allowed set); nothing has needed that. To add a network, edit
`ALLOW4` in the script, reinstall it and run `ssh-firewall.sh apply`.
