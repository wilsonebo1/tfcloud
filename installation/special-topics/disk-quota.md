# Disk quota

IDE and secureworker can have disk quotas enabled for them.
Disk quotas for secureworker are supported in dockerized and Cloudera Hadoop deploys.

## Configuring quotas

There is only one StorageAllocator that supports quotas.
It is the `BtrfsStorageAllocator` class.
For it to work the context directories have to be on a btrfs fylesystem.
The settings that enable quotas are very similar for the IDE and for the secureworker.

* IDE:
 * IDE_WORKER_STORAGE_ALLOCATOR_CLASS
 * IDE_WORKER_STORAGE_QUOTA_GB
* Secureworker:
 * SECURE_WORKER_STORAGE_ALLOCATOR_CLASS
 * SECURE_WORKER_STORAGE_QUOTA_GB

IDE_WORKER_STORAGE_ALLOCATOR_CLASS and SECURE_WORKER_STORAGE_ALLOCATOR_CLASS variables default to `DirectoryStorageAllocator` which doesn't provide any limiting capabilities.
To enable quotas you need to set them to `BtrfsStorageAllocator`.
Keep in mind that default quota limits are low, they default to 10G.
Next, you have to ensure that contexts are created in the btrfs root.
I'll assume that you have /opt/ctx mounted as btrfs FS with quotas enabled.
For dockerized deploys you need to set HOST_CONTEXT_BASE to point to /opt/ctx.
This variable is used both in application to correctly generate volume definitions and in ansible provisioning to generate correct mounts for the ide/sw workers.
For Cloudera Hadoop deploys you need to set `yarn_nodemanager_local_dirs` to point to a btrfs root.
The system will autoconfigure the rest.
Settings for IDE disk quotas are the same in both deploys.

## IDE usage concerns

Due to the way quotas work on btrfs file systems, if you hit the limit, you can't:
 * delete a file to free up space
 * erase part of an existing file to free up blocks
If you hit the limit you are left with not so many options. If you have admin rights, you can rise quota and delete excessive data and then bring the limit back.
If you don't - you are out of options.
As a consequence of this behavior, if an IDE user hits the limit and gets a 'Quota exceeded' error, he/she needs to logout.
The system will delete the user's IDE container and they can start from a fresh one.
