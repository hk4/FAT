# FUSE FAT

This repo implements a simplified FAT filesystem, using Linux FUSE (libfuse) as an interface.

## Compiling, Running and Testing

To compile, simply type:

```
make
```

Once the code is compiled, there will be an executable called `fat.o`. To run, type:

```
./fat -s [test directory]
```

A file named `fat_disk` with size 10MB will be created when the program is run for the first time. All updates are persisted in the `fat_disk` file.

Some tests:

- Maximum empty directories: 
```
./stest
 ``` 
Will simply return the maximum number of empty directories for the filesystem. It also include a verbose mode "-v" that prints names of the folders to the out as they are written to the filesystem.

## Implementation details

We designed our filesystem by modelling on the FAT32 architecture. However, there are some important differences in implementation details.

### Boot sector

The boot sector is located at cluster 0 and is represented by `struct fat_superblock`. The table below describes the content of the boot sector:

Byte offset | Length (bytes) | Content                     | Default value
:----------:|:--------------:|:----------------------------|:-------------:
0           | 4              | Number of bytes per cluster | 4096
4           | 4              | Number of clusters          | 2560
8           | 4              | Number of clusters per FAT  | 3
12          | 4              | FAT type                    | 32
16          | 4              | First cluster of root       | 4
20          | 4              | First cluster of free list  | 5

From the table, we can see that there are 2560 clusters of 4096 bytes. This is because 10MB/4096B = 2560. Since we are implementing FAT32, each FAT entry will be 4 bytes, and so each cluster can have at most 4096/4 = 1024 entries. Therefore, we only need 3 clusters to hold the number of clusters in the data region.

The boot sector is stored in memory during the execution of the filesystem. Whenever it is updated in memory, it will be written back to `fat_disk`.

### FAT

The FAT is located at cluster 1, and by default spans 3 clusters (as shown in the boot sector table above). When our filesystem is running, the FAT will be read into memory. Any changes to the FAT will first happen in memory and then be written to `fat_disk`. The possible values for FAT entry are `0x0` to indicate end of cluster chain and any other legal positive numbers to indicate the number of the next cluster in a chain. Initially, when FAT is first created, all entries (except for the root cluster entry) will point to the cluster right next to it because they are all free.

### Data region

The data region starts at cluster 4, right after FAT. The root cluster is also cluster 4. A cluster is updated by first reading the cluster from disk into memory, changing it in memory, and then writing the entire back into `fat_disk`.

### Directory entry

Each directory entry is 32 bytes and is represented by `struct fat_dir_entry`. The detail is in the table below:

Byte offset | Length (bytes) | Content
:----------:|:--------------:|:----------
0           | 22             | File name (including extension and "."). If first byte is 0, the entry is free. Max length is 21.
22          | 2              | File type. 0 for file, 1 for sub directory, 2 for symbolic link
24          | 4              | File size in bytes. If the entry is not for a file, then the size is 0.
28          | 4              | Number of first cluster

No permission or date are kept. Long file name is not supported.
