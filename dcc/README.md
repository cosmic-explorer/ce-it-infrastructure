First convery the image from Phillipe to a Docker image

```sh
virt-tar-out -a dcc-syr-disk0.qcow2 / - | docker import - sugwg/dcc-base:latest
```

Next build the image
```sh
docker build --rm -t sugwg/dcc:latest .
```

Customize `docker-compose.yml` and start the image with
```sh
docker-compose up --detach
```
