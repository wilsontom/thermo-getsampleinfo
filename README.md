# thermo-getsampleinfo

Docker image for running the R `GetSampleInfo` package with Thermo RawFileReader support.

## Build

Build the image from this directory:

```sh
docker build -t thermo-getsampleinfo .
```

To build against a specific `GetSampleInfo` branch, tag, or commit:

```sh
docker build --build-arg GETSAMPLEINFO_REF=master -t thermo-getsampleinfo .
```

## Run

This image does not bundle Thermo RawFileReader `.dll` files. Put the
RawFileReader files on the host, then mount that directory at
`/opt/RawFileReader` in the container.

For example, if the Thermo `.dll` files are in `./RawFileReader`:

```sh
docker run --rm -it -v "$PWD/RawFileReader:/opt/RawFileReader:ro" thermo-getsampleinfo
```

To also mount a directory containing Thermo `.raw` files:

```sh
docker run --rm -it \
  -v "$PWD/RawFileReader:/opt/RawFileReader:ro" \
  -v "$PWD:/data" \
  thermo-getsampleinfo
```

Inside R, load the package and work with files under `/data`:

```r
library(GetSampleInfo)
help(package = "GetSampleInfo")
```

The container uses `THERMO_RAWFILEREADER_HOME=/opt/RawFileReader` by default.
On first start, it compiles RawFileReader support from the mounted `.dll`
files if needed.
