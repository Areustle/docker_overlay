# docker overlay filesystem example

run successfully on linux host. TODO: get working with s3 bucket.

## initialization 

``` bash
mkdir -p lower overlayfs/{upper,work} merged
# optional: touch lower/readonly.txt
```

## build the image

docker build -t overlaytest .

## run the container with valid mounts

``` bash
docker run --rm -it \
  --cap-add=SYS_ADMIN \
  --security-opt apparmor=unconfined \
  -v ./lower:/mnt/lower:ro \
  -v ./overlayfs:/mnt/overlayfs \
  -v ./merged:/mnt/merged \
  overlaytest
```

mounting is handled at container creation with the entrypoint.sh script.

## demonstrate overlay filesystem within container

`/mnt/merged/` is the unified filesystem, it is the result of the kernel overlaying
`/mnt/overlayfs/upper` ontop of `/mnt/lower`. users opaquely see `/mnt/merged/` as
their filesystem, and can make changes or add files.

``` bash
root@9ae181a806bf:/# ls /mnt/merged/
foo.txt
```

foo.txt is our base, readonly data. let's add our own file, the result of manipulating
the filesystem during an XMM analysis.

``` bash
root@9ae181a806bf:/# touch /mnt/merged/bar.txt 
root@9ae181a806bf:/# ls /mnt/merged/
bar.txt  foo.txt
```

bar.txt is now in /mnt/merged, but not in /mnt/lower (the ro mount)

``` bash
root@9ae181a806bf:/# ls mnt/lower/
foo.txt
```

where is it? in `/mnt/overlayfs/upper/`

``` bash
root@9ae181a806bf:/# ls /mnt/overlayfs/upper/
bar.txt
```

and `/mnt/merged/` is the union of the two. This separation allows you to segregate user data from mission data, while giving users the illusion of unified access to a single filesystem. The user never needs to know about the upper/lower plumbing.

metadata management in maintained in `/mnt/work/`, see [kernel documentation](https://docs.kernel.org/filesystems/overlayfs.html) for details. All directory names are arbitrary and can be altered for the 
container's use case.
