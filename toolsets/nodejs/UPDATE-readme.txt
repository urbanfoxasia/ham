# Updating

## 1 - Bumping to Latest Nodejs & Modules

Download latest 6.x.x from [official release page](https://nodejs.org/en/download/releases):
```
$ wget https://nodejs.org/download/release/v6.14.4/node-v6.14.4-darwin-x64.tar.gz
```

Unpack the tarball:
```
$ tar zxfp node-v6.14.4-darwin-x64.tar.gz
```

Symlinking:
```
$ mkdir 6.14.4
$ mv node-v6.14.4-darwin-x64 6.14.4/osx-x86
$ ln -sf 6.14.4/osx-x86 osx-x86
```

Installing the dependencies:
```
$ ./npm-install-global-deps
```

Check to ensure the apps using `ham-node` continue to work as expected.

## 2 - Packing & Releasing

Packing the self-contained nodejs & modules dir:
```
$ 7z-pack-dir nodejs-v6.14.4-npm-pkgs_ty-20180928_osx-x86.7z osx-x86
```

Then upload the 7z archive to s3.
