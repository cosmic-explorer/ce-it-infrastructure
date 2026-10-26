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
