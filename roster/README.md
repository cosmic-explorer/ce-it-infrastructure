# CE COmanage Instance

Build using
```sh
. build-comanage.sh
```
and run using
```sh
docker stack deploy --compose-file comanage-registry-stack.yml comanage-registry
```

Edit the file `/srv/docker/comanage/srv/comanage-registry/local/Config/email.php` and remove the lines
```php
    'username' => 'account@gmail.com',
    'password' => 'password'
```
as well as the `,` on the preceeding line.
