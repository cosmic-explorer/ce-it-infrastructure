# CE DCC Image

This systems requres an image of the DCC VM `dcc-syr-disk0.qcow2`

Build using 
```sh
. build-dcc.sh
```
and deploy with
```sh
docker stack deploy --compose-file dcc-stack.yml dcc
```
